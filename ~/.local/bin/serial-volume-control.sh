#!/usr/bin/env bash

# Serial port setup
PORT=/dev/ttyACM0
BAUD=9600

# Set up the serial port
stty -F $PORT $BAUD raw -echo

# Get the main sink name
SINK=$(pactl list sinks short | head -1 | cut -f2)
echo "Using audio sink: $SINK"

# Function to set volume for main sink
set_master_volume() {
    local value=$1
    # Convert to percentage (0-100)
    local volume=$((value * 100 / 1023))
    echo "Setting master volume to $volume%"
    pactl set-sink-volume $SINK ${volume}%
}

# Function to set volume for a specific application
set_app_volume() {
    local value=$1
    local app_name=$2

    # Convert to percentage (0-100)
    local volume=$((value * 100 / 1023))

    # Find sink inputs matching the app name
    pactl list sink-inputs | grep -B 20 "application.name = \"$app_name\"" | grep "Sink Input #" | grep -o '[0-9]\+' | while read -r sink_input; do
        echo "Setting $app_name volume to $volume% (sink input #$sink_input)"
        pactl set-sink-input-volume $sink_input ${volume}%
    done
}

echo "Starting volume control, press Ctrl+C to exit"
echo "Reading from $PORT at $BAUD baud"

# Read from serial port
while IFS='|' read -r -d $'\n' line; do
    echo "Received: $line"

    # Split the line by '|'
    IFS='|' read -ra values <<< "$line"

    # Process each slider value
    if [[ "${values[0]}" =~ ^[0-9]+$ ]]; then
        set_master_volume ${values[0]}
    fi

    # Check if we have more values
    if [[ "${#values[@]}" -gt 1 && "${values[1]}" =~ ^[0-9]+$ ]]; then
        set_app_volume ${values[1]} "Google Chrome"
    fi

    if [[ "${#values[@]}" -gt 2 && "${values[2]}" =~ ^[0-9]+$ ]]; then
        set_app_volume ${values[2]} "firefox"
    fi

    if [[ "${#values[@]}" -gt 3 && "${values[3]}" =~ ^[0-9]+$ ]]; then
        set_app_volume ${values[3]} "Discord"
    fi

    if [[ "${#values[@]}" -gt 4 && "${values[4]}" =~ ^[0-9]+$ ]]; then
        set_app_volume ${values[4]} "spotify"
    fi

done < $PORT
