#!/bin/bash

# File: alert.sh
# Location: /home/sub0x/dotfiles/scripts/alert.sh
# Description: Interactively sets a timed alert with a custom message that triggers a persistent desktop notification and plays a sound at the specified time.
# Usage: ./alert.sh

# Function to validate time format
validate_time() {
    if [[ $1 =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Prompt for alert time
while true; do
    read -p "Enter alert time (HH:MM): " alert_time
    if validate_time "$alert_time"; then
        break
    else
        echo "Invalid time format. Please use HH:MM (24-hour format)."
    fi
done

# Prompt for description
read -p "Enter alert description: " description

current_time=$(date +%s)
alert_timestamp=$(date -d "today $alert_time" +%s)

# If the specified time has already passed today, set for tomorrow
if (( alert_timestamp < current_time )); then
    alert_timestamp=$(date -d "tomorrow $alert_time" +%s)
fi

sleep_time=$((alert_timestamp - current_time))

# Set the alert
(
    sleep $sleep_time
    export DISPLAY=:0  # Ensure the notification appears on the correct display
    notify-send --urgency=critical --icon=dialog-information --expire-time=0 "Alert: $description" "It's now $alert_time"
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga
) &

echo "Alert \"$description\" set for $alert_time"
echo "PID of alert process: $!"
