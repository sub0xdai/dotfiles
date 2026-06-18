#!/bin/bash
set -e -x

setup_sub0xdai_repo() {
    local repo_visibility="private"
    local visibility_set_by_flag=""
    local commit_message="Initial commit: Add README"
    
    # Parse options
    while getopts "pm:" opt; do
        case $opt in
            p) repo_visibility="public"; visibility_set_by_flag="true" ;;
            m) commit_message="$OPTARG" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
        esac
    done
    shift $((OPTIND-1))
    
    # Get repo name from argument or current directory
    if [ -z "$1" ]; then
        repo_name=$(basename "$PWD")
    else
        repo_name="$1"
        mkdir -p "$repo_name"
        cd "$repo_name"
    fi 

    # Initialize git if needed
    if ! test -d './.git' ; then
        git init
    fi 
    
    # Add files and make initial commit
    if [ -z "$(git status --porcelain)" ]; then
        # Create a dummy file if the directory is empty
        echo "# $repo_name" > README.md
        echo "Created on: $(date)" >> README.md
        git add README.md
    else
        git add .
    fi
    git commit -m "$commit_message" --no-verify

    # Color definitions
    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
    BOLD='\033[1m'

    # If visibility wasn't set by flag, prompt for it
    if [ "$repo_visibility" = "private" ] && [ -z "$visibility_set_by_flag" ]; then
        echo -e "\n\033[1mRepository Visibility\033[0m"
        echo -e "===================="
        echo -e "\033[0;36m1)\033[0m Private"
        echo -e "\033[0;36m2)\033[0m Public"
        echo -e "\n"
        read -p "Choose option: " visibility_choice
        
        case $visibility_choice in
            2)
                repo_visibility="public"
                ;;
            *)
                repo_visibility="private"
                ;;
        esac
    fi

    # Create repo on GitHub and set up remote
    if command -v gh &> /dev/null; then
        echo -e "\n\033[1mRepository Location\033[0m"
        echo -e "=================="
        echo -e "\033[0;36m1)\033[0m tehuticode"
        echo -e "\033[0;36m2)\033[0m sub0xdai"
        echo -e "\033[0;36m3)\033[0m other"
        echo -e "\n"
        read -p "Choose option: " repo_location
        
        case $repo_location in
            1)
                org="tehuticode"
                git_host="git@github.com"
                # Always switch to tehuticode
                gh auth logout 2>/dev/null || true
                gh auth login --hostname github.com --git-protocol ssh --web
                ;;
            2)
                org="sub0xdai"
                git_host="git@github-sub0xdai"
                # Always switch to sub0xdai
                gh auth logout 2>/dev/null || true
                gh auth login --hostname github.com --git-protocol ssh --web
                ;;
            3)
                echo -e "\n"
                read -p "Enter organization: " org
                git_host="git@github.com"
                ;;
            *)
                echo -e "\n\033[0;34mUsing tehuticode as default.\033[0m"
                org="tehuticode"
                git_host="git@github.com"
                gh auth logout 2>/dev/null || true
                gh auth login --hostname github.com --git-protocol ssh --web
                ;;
        esac
        
        echo -e "\n${BOLD}Creating ${repo_visibility} repository on GitHub under ${org}...${NC}\n"
        
        # Remove existing remote if it exists
        git remote remove origin 2>/dev/null || true
        
        # Create the repository first
        gh repo create "$org/$repo_name" --"$repo_visibility" yes >/dev/null 2>&1 || true
        
        # Then set up the remote
        git remote add origin "${git_host}:${org}/${repo_name}.git"
        
        # Push the code
        echo "Pushing to ${git_host}:${org}/${repo_name}.git"
        
        # Ensure the correct SSH URL is set
        git remote set-url origin "${git_host}:${org}/${repo_name}.git"
        echo "Updated remote URL to: ${git_host}:${org}/${repo_name}.git"
        
        git push -u origin HEAD --no-verify
        git status
    else
        echo "GitHub CLI not found. Please enter your GitHub repository URL:"
        read -p "> " github_url
        
        if [ -n "$github_url" ]; then
            git remote add origin "$github_url"
            new_url=$(echo "$github_url" | sed 's/github.com/github-sub0xdai/')
            git remote set-url origin "$new_url"
            echo "Updated remote URL to: $new_url"
        else
            echo "No URL provided. Please add remote manually later."
            return 1
        fi
    fi

    # Push to remote
    git push -u origin HEAD --no-verify
    git status
}

# Function to check if git is installed
ensure_git() {
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Installing git..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        elif command -v brew &> /dev/null; then
            brew install git
        else
            echo "Could not install git. Please install it manually."
            exit 1
        fi
    fi
}

# Main execution
main() {
    ensure_git
    setup_sub0xdai_repo "$@"
}

main "$@"
