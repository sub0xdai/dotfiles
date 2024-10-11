#!/bin/bash

echo "#===================="
echo "# WALLPAPERS"
echo "#===================="
echo

# Loop through all image files in the Pictures directory
for file in ~/Pictures/*.{jpg,png}; do
    # Check if the file exists (this is necessary to handle cases where there are no matches)
    [ -e "$file" ] || continue
    
    # Generate the config line
    echo "exec_always --no-startup-id feh --bg-scale $file"
done

