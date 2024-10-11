if type "xrandr" > /dev/null; then
    if xrandr --query | grep "HDMI-0 connected"; then
        MONITOR=HDMI-0 polybar --reload toph &
    fi
else
    polybar --reload toph &
fi
