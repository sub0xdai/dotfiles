#!/bin/bash

# Function to set git config for sub0xdai projects
setup_git_config() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not a git repository!"
        return 1
    }

    # Get the current remote URL
    current_url=$(git remote get-url origin 2>/dev/null)
    
    if [ -n "$current_url" ]; then
        # If URL contains github.com, replace it with github-sub0xdai
        if [[ $current_url == *"github.com"* ]]; then
            new_url=$(echo $current_url | sed 's/github.com/github-sub0xdai/')
            git remote set-url origin $new_url
            echo "Updated remote URL to: $new_url"
        fi
    else
        echo "No remote 'origin' found"
    fi
}

# Run the function
setup_git_config
