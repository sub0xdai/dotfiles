#!/bin/bash
# ~/.config/i3/scripts/__manage_monitors.sh
# Detects monitor configuration and sets up workspaces accordingly

detect_monitors() {
    DP1_ACTIVE=$(xrandr | grep "DP-1 connected" | grep -v "disconnected" | wc -l)
    HDMI0_ACTIVE=$(xrandr | grep "HDMI-0 connected" | grep -v "disconnected" | wc -l)
    
    if [ $DP1_ACTIVE -eq 1 ] && [ $HDMI0_ACTIVE -eq 1 ]; then
        echo "dual"
    elif [ $DP1_ACTIVE -eq 1 ] || [ $HDMI0_ACTIVE -eq 1 ]; then
        echo "single"
    else
        echo "none"
    fi
}

setup_dual_monitors() {
    echo "Setting up dual monitor workspace layout..."
    
    # Your preferred dual monitor setup
    xrandr --output HDMI-0 --primary --mode 3840x2160 --output DP-1 --mode 1920x1080 --left-of HDMI-0
    
    # Move workspaces to preferred monitors
    # Left monitor (DP-1): 1, 9, 0
    i3-msg "workspace 1; move workspace to output DP-1"
    i3-msg "workspace 9; move workspace to output DP-1" 
    i3-msg "workspace 0; move workspace to output DP-1"
    
    # Right monitor (HDMI-0): 2-8
    for ws in 2 3 4 5 6 7 8; do
        i3-msg "workspace $ws; move workspace to output HDMI-0"
    done
    
    # Focus workspace 1
    i3-msg "workspace 1"
}

setup_single_monitor() {
    echo "Setting up single monitor workspace layout..."
    
    # Determine which monitor is active and configure
    DP1_ACTIVE=$(xrandr | grep "DP-1 connected" | grep -v "disconnected" | wc -l)
    HDMI0_ACTIVE=$(xrandr | grep "HDMI-0 connected" | grep -v "disconnected" | wc -l)
    
    if [ $DP1_ACTIVE -eq 1 ]; then
        xrandr --output DP-1 --primary --mode 1920x1080 --output HDMI-0 --off
        PRIMARY_OUTPUT="DP-1"
    elif [ $HDMI0_ACTIVE -eq 1 ]; then
        xrandr --output HDMI-0 --primary --mode 3840x2160 --output DP-1 --off
        PRIMARY_OUTPUT="HDMI-0"
    fi
    
    # Move all workspaces to the active monitor in sequential order
    for ws in 1 2 3 4 5 6 7 8 9 0; do
        i3-msg "workspace $ws; move workspace to output $PRIMARY_OUTPUT"
    done
    
    # Focus workspace 1
    i3-msg "workspace 1"
}

main() {
    MONITOR_CONFIG=$(detect_monitors)
    
    case $MONITOR_CONFIG in
        "dual")
            setup_dual_monitors
            ;;
        "single")
            setup_single_monitor
            ;;
        "none")
            echo "No monitors detected!"
            exit 1
            ;;
    esac
}

main
