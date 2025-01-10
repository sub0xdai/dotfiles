#!/bin/bash

# Set the base directory for your Obsidian vault
VAULT_DIR="$HOME/1-project/vaults/sub0x_vault/5-notes/2024"

# Function to extract year from filename
get_year() {
    echo "$1" | grep -oE '^[0-9]{4}'
}

# Function to validate date format (YYYY-MM-DD)
is_valid_date() {
    local filename="$1"
    if [[ $filename =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        return 0
    else
        return 1
    fi
}

# Process files in the current directory
process_files() {
    for file in *.md; do
        # Skip if no markdown files found
        [[ -f "$file" ]] || continue
        
        # Check if filename contains a valid date
        if is_valid_date "$file"; then
            year=$(get_year "$file")
            target_dir="$VAULT_DIR/$year"
            
            # Create year directory if it doesn't exist
            mkdir -p "$target_dir"
            
            # Move file to appropriate year directory
            mv "$file" "$target_dir/"
            echo "Moved $file to $target_dir/"
        fi
    done
}

# Main execution
if [ -d "$VAULT_DIR" ]; then
    process_files
else
    echo "Error: Vault directory not found at $VAULT_DIR"
    exit 1
fi