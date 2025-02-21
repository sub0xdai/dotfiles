#!/bin/bash

# Log the execution
echo "xautolock wrapper executed at $(date)" >> /tmp/xautolock_wrapper.log

# Export the display
export DISPLAY=:0

# Execute the lock script
/home/m0xu/dotfiles/scripts/betterlock_single_display.sh
