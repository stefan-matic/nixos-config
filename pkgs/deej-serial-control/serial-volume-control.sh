#!/usr/bin/env bash

# Serial port setup
PORT=/dev/ttyACM0
BAUD=9600

# Set up the serial port
stty -F $PORT $BAUD raw -echo

# Get the main sink name
SINK=$(pactl list sinks short | head -1 | cut -f2)
echo "Using audio sink: $SINK"

# Cache for previous values to avoid unnecessary updates
declare -A PREV_VALUES
PREV_VALUES[0]="-1"
PREV_VALUES[1]="-1"
PREV_VALUES[2]="-1"
PREV_VALUES[3]="-1"
PREV_VALUES[4]="-1"

# Throttle variables
THROTTLE_INTERVAL=0.1  # seconds between updates
last_update=$(date +%s.%N)

# Debug level (0=minimal, 1=normal, 2=verbose)
DEBUG_LEVEL=0

# Print debug messages based on level
debug() {
    local level=$1
    local message=$2
    if [[ $level -le $DEBUG_LEVEL ]]; then
        echo "$message"
    fi
}

# Function to set volume for main sink
set_master_volume() {
    local value=$1
    local prev_value=${PREV_VALUES[0]}

    # Skip if the value hasn't changed significantly (within 1%)
    if [[ $value -ge $((prev_value - 10)) && $value -le $((prev_value + 10)) ]]; then
        return
    fi

    # Convert to percentage (0-100)
    local volume=$((value * 100 / 1023))
    debug 1 "Setting master volume to $volume%"
    pactl set-sink-volume $SINK ${volume}% 2>/dev/null
    PREV_VALUES[0]=$value
}

# Function to set volume for a specific application
set_app_volume() {
    local value=$1
    local app_name=$2
    local index=$3
    local prev_value=${PREV_VALUES[$index]}

    # Skip if the value hasn't changed significantly (within 1%)
    if [[ $value -ge $((prev_value - 10)) && $value -le $((prev_value + 10)) ]]; then
        return
    fi

    # Convert to percentage (0-100)
    local volume=$((value * 100 / 1023))

    # Find sink inputs matching the app name
    pactl list sink-inputs 2>/dev/null | grep -B 20 "application.name = \"$app_name\"" | grep "Sink Input #" | grep -o '[0-9]\+' | while read -r sink_input; do
        debug 1 "Setting $app_name volume to $volume% (sink input #$sink_input)"
        pactl set-sink-input-volume $sink_input ${volume}% 2>/dev/null
    done

    PREV_VALUES[$index]=$value
}

debug 0 "Starting volume control, press Ctrl+C to exit"
debug 0 "Reading from $PORT at $BAUD baud"

# Read from serial port
while IFS='|' read -r -d $'\n' line || true; do
    # Apply throttling to reduce CPU usage
    current_time=$(date +%s.%N)
    time_diff=$(echo "$current_time - $last_update" | bc)
    if (( $(echo "$time_diff < $THROTTLE_INTERVAL" | bc -l) )); then
        sleep 0.05
        continue
    fi
    last_update=$current_time

    debug 2 "Received: $line"

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
        set_app_volume ${values[4]} "spotify" 4
    fi

done < $PORT
