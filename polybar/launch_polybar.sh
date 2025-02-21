#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar only on HDMI-0
if type "xrandr" > /dev/null; then
    if xrandr --query | grep "HDMI-0 connected"; then
        MONITOR=HDMI-0 polybar --reload toph &
    fi
fi

echo "Polybar launched..."
