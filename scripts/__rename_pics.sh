
#!/bin/bash

# Change to the Pictures directory
cd ~/Pictures

# Initialize a counter
count=1

# Loop through all image files (jpg, png, etc.)
for file in *.jpg *.png; do
    # Check if the file exists (this is necessary to handle cases where there are no matches)
    [ -e "$file" ] || continue
    
    # Get the file extension
    ext="${file##*.}"
    
    # Rename the file
    mv "$file" "${count}.${ext}"
    
    # Increment the counter
    ((count++))
done

echo "Renaming complete!"

