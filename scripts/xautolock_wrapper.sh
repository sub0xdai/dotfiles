#!/bin/bash

# Log the execution
echo "xautolock wrapper executed at $(date)" >> /tmp/xautolock_wrapper.log

# Export the display
export DISPLAY=:0

# Execute the lock script
/home/sub0x/dotfiles/scripts/betterlock_single_display.sh
