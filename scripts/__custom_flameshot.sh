#!/bin/bash

# Create screenshots directory in /tmp if it doesn't exist
mkdir -p /tmp/screenshots

# Get timestamp for unique filename
timestamp=$(date +%Y%m%d_%H%M%S)
tmp_path="/tmp/screenshots/screenshot_$timestamp.png"

# Launch flameshot in GUI mode without saving automatically
flameshot gui

# Monitor clipboard for changes
# When a new image is detected in clipboard, save it to /tmp/screenshots
sleep 0.5  # Wait for clipboard to be updated
xclip -selection clipboard -t image/png -o > "$tmp_path"

# Check if the file was created and has content
if [ -f "$tmp_path" ] && [ -s "$tmp_path" ]; then
    # Optional: Show notification
    notify-send "Screenshot saved" "Saved to $tmp_path"
fi
