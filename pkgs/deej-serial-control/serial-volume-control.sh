#!/usr/bin/env bash

# Serial port setup
PORT=/dev/ttyACM0
BAUD=9600

# Wait for the device to be available (max 5 seconds)
for i in {1..5}; do
  if [ -e "$PORT" ]; then
    break
  fi
  echo "Waiting for device $PORT... ($i/5)"
  sleep 0.5
done

# Check if the device exists
if [ ! -e "$PORT" ]; then
  echo "Error: Serial port $PORT not found after waiting. Exiting."
  exit 1
fi

# Set up the serial port with reliable settings
stty -F $PORT $BAUD raw -echo

# Function to get the audio sink
get_audio_sink() {
  # Try to get the default sink
  local sink
  sink=$(pactl get-default-sink 2>/dev/null)

  # If that failed, try the old method
  if [ -z "$sink" ]; then
    sink=$(pactl list sinks short 2>/dev/null | head -1 | cut -f2)
  fi

  echo "$sink"
}

# Wait for audio system to initialize (try for 10 seconds)
for i in {1..20}; do
  SINK=$(get_audio_sink)
  if [ -n "$SINK" ]; then
    echo "Using audio sink: $SINK"
    break
  fi
  echo "Waiting for audio system to initialize... ($i/20)"
  sleep 0.5
done

# Cache for previous values to avoid unnecessary volume changes
declare -A PREV_VOLUMES
for i in {0..4}; do
  PREV_VOLUMES[$i]=-1
done

# Track when we last refreshed the sink
LAST_SINK_REFRESH=$(date +%s)

# Minimum change threshold (out of 1023) to register a new value
# Lower value means more responsiveness but more CPU usage
CHANGE_THRESHOLD=3

# Verbosity (0=quiet, 1=normal, 2=verbose)
VERBOSE=1

log() {
  local level=$1
  local message=$2
  if [[ $VERBOSE -ge $level ]]; then
    echo "$message"
  fi
}

# Function to set volume for main sink
set_master_volume() {
  local value=$1

  # Check if we need to refresh the sink (every 15 seconds)
  local now=$(date +%s)
  if [[ $((now - LAST_SINK_REFRESH)) -gt 15 ]]; then
    local new_sink=$(get_audio_sink)
    if [[ -n "$new_sink" && "$new_sink" != "$SINK" ]]; then
      SINK="$new_sink"
      log 1 "Updated audio sink to: $SINK"
    fi
    LAST_SINK_REFRESH=$now
  fi

  # If no sink, skip this update
  if [ -z "$SINK" ]; then
    return
  fi

  # Convert to percentage (0-100)
  local volume=$((value * 100 / 1023))

  # Update if the volume has changed at all
  if [[ $volume -ne ${PREV_VOLUMES[0]} ]]; then
    log 1 "Setting master volume to $volume%"
    if pactl set-sink-volume "$SINK" ${volume}% 2>/dev/null; then
      PREV_VOLUMES[0]=$volume
    else
      # If command failed, try to refresh the sink immediately
      SINK=$(get_audio_sink)
      log 1 "Refreshed sink after failure: $SINK"
      # Try again with the new sink
      if [ -n "$SINK" ]; then
        pactl set-sink-volume "$SINK" ${volume}% 2>/dev/null && PREV_VOLUMES[0]=$volume
      fi
    fi
  fi
}

# Function to set volume for a specific application
set_app_volume() {
  local value=$1
  local app_name=$2
  local index=$3

  # Convert to percentage (0-100)
  local volume=$((value * 100 / 1023))

  # Update if the volume has changed at all
  if [[ $volume -ne ${PREV_VOLUMES[$index]} ]]; then
    # Find sink inputs matching the app name
    local sink_inputs
    sink_inputs=$(pactl list sink-inputs 2>/dev/null | grep -B 20 "application.name = \"$app_name\"" | grep "Sink Input #" | grep -o '[0-9]\+')

    if [[ -n "$sink_inputs" ]]; then
      log 1 "Setting $app_name volume to $volume%"
      echo "$sink_inputs" | while read -r sink_input; do
        pactl set-sink-input-volume $sink_input ${volume}% 2>/dev/null
      done
      PREV_VOLUMES[$index]=$volume
    fi
  fi
}

log 0 "Starting volume control"
log 0 "Reading from $PORT at $BAUD baud"

# Main loop - back to original approach but with faster looping
exec < $PORT
while read -r line; do
  log 2 "Received: $line"

  # Skip empty lines
  if [[ -z "$line" ]]; then
    continue
  fi

  # Split the line by '|'
  IFS='|' read -ra values <<< "$line"

  # Process each slider value
  if [[ "${#values[@]}" -gt 0 && "${values[0]}" =~ ^[0-9]+$ ]]; then
    set_master_volume ${values[0]}
  fi

  # Check if we have more values
  if [[ "${#values[@]}" -gt 1 && "${values[1]}" =~ ^[0-9]+$ ]]; then
    set_app_volume ${values[1]} "Google Chrome" 1
  fi

  if [[ "${#values[@]}" -gt 2 && "${values[2]}" =~ ^[0-9]+$ ]]; then
    set_app_volume ${values[2]} "firefox" 2
  fi

  if [[ "${#values[@]}" -gt 3 && "${values[3]}" =~ ^[0-9]+$ ]]; then
    set_app_volume ${values[3]} "Discord" 3
  fi

  if [[ "${#values[@]}" -gt 4 && "${values[4]}" =~ ^[0-9]+$ ]]; then
    set_app_volume ${values[4]} "Warframe.x64.exe" 4
  fi
done
