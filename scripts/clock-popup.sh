#!/bin/bash

PID_FILE="/tmp/i3-popup.pid"

# --- STOP LOGIC ---
if [ "$1" == "--stop" ]; then
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill "$PID" 2>/dev/null
        rm "$PID_FILE"
    fi
    exit 0
fi

# Prevent multiple instances if key is held/spammed
if [ -f "$PID_FILE" ]; then exit 0; fi

# --- DISPLAY LOGIC ---
if [ "$1" == "--info" ]; then
    # Down Arrow: Show Battery, CPU, and Date
    # We use 'watch' to keep the info updating every second
    COMMAND="watch -t -n 1 'echo \"BATTERY: \$(upower -i \$(upower -e | grep BAT) | grep percentage | awk \"{print \$2}\")\"; echo \"----------------\"; free -h | awk \"/^Mem:/ {print \\\"RAM:  \\\" \$3 \\\" / \\\" \$2}\"; echo \"----------------\"; date \"+%A, %d %B\"; date \"+%I:%M:%S %p\"'"
else
    # Other Arrows: Show Clock
    COMMAND="tty-clock -c -C 4 -B"
fi

# Launch Kitty
kitty --class="clock-floater" \
      -o "window_padding_width=15" \
      -o "initial_window_width=400" \
      -o "initial_window_height=250" \
      -e sh -c "$COMMAND" &

echo $! > "$PID_FILE"
