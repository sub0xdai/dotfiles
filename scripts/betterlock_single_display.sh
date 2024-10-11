#!/bin/bash

# Function to log out and sleep
logout_and_sleep() {
    i3-msg exit
    sleep 1 && systemctl hybrid-sleep
}

# Turn off the DP-1 display
xrandr --output DP-1 --off

# Lock the screen on the HDMI display
betterlockscreen -l dim &
LOCK_PID=$!

# Start a timer in the background
(
    sleep 1800  # 30 minutes
    if ps -p $LOCK_PID > /dev/null; then
        # If the lock screen is still active after 30 minutes, logout and sleep
        logout_and_sleep
    fi
) &

# Wait for the lock screen to be dismissed
wait $LOCK_PID

# Turn the DP-1 display back on after unlocking
xrandr --output DP-1 --auto --left-of HDMI-0
