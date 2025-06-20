#!/bin/bash

# Kebab Case File Renamer for Obsidian Vault
# Recursively finds files with spaces and converts them to kebab-case
# Usage: ./__kebab_case.sh [target_directory]

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default target directory
TARGET_DIR="${1:-.}"

# Validate target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist${NC}"
    exit 1
fi

echo -e "${BLUE}Starting kebab-case conversion in: $TARGET_DIR${NC}"
echo -e "${BLUE}========================================${NC}"

# Counters
files_found=0
files_renamed=0
errors=0

# Function to convert string to kebab-case
to_kebab_case() {
    local input="$1"
    # Convert to lowercase, replace spaces with hyphens, clean up special chars
    echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]\+/-/g' | sed 's/[^a-z0-9.-]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
}

# Function to safely rename file
rename_file() {
    local old_path="$1"
    local dir_path=$(dirname "$old_path")
    local old_name=$(basename "$old_path")
    local new_name=$(to_kebab_case "$old_name")
    local new_path="$dir_path/$new_name"
    
    # Skip if already kebab-case
    if [[ "$old_name" == "$new_name" ]]; then
        return 0
    fi
    
    echo -e "${YELLOW}Found:${NC} $old_path"
    
    # Check if target already exists
    if [[ -e "$new_path" ]]; then
        echo -e "${RED}  Error: Target file already exists: $new_path${NC}"
        ((errors++))
        return 1
    fi
    
    # Attempt rename
    if mv "$old_path" "$new_path" 2>/dev/null; then
        echo -e "${GREEN}  Renamed to:${NC} $new_path"
        ((files_renamed++))
        return 0
    else
        echo -e "${RED}  Error: Failed to rename file${NC}"
        ((errors++))
        return 1
    fi
}

# Main processing loop - find files AND directories with spaces
# Process directories first (bottom-up) to avoid path issues
while IFS= read -r -d '' item; do
    item_name=$(basename "$item")
    # Check if name contains spaces
    if [[ "$item_name" =~ [[:space:]] ]]; then
        ((files_found++))
        if [[ -d "$item" ]]; then
            echo -e "${BLUE}[DIR]${NC} Processing directory..."
        fi
        rename_file "$item"
    fi
done < <(find "$TARGET_DIR" -depth -print0)

# Summary report
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Conversion Summary:${NC}"
echo -e "Items with spaces found: ${YELLOW}$files_found${NC}"
echo -e "Items successfully renamed: ${GREEN}$files_renamed${NC}"
echo -e "Errors encountered: ${RED}$errors${NC}"

if [[ $files_found -eq 0 ]]; then
    echo -e "${GREEN}No files or directories with spaces found - naming convention already adhered to!${NC}"
elif [[ $files_renamed -eq $files_found ]]; then
    echo -e "${GREEN}All files successfully converted to kebab-case!${NC}"
elif [[ $errors -gt 0 ]]; then
    echo -e "${YELLOW}Some files could not be renamed due to conflicts or permissions${NC}"
    exit 1
fi
