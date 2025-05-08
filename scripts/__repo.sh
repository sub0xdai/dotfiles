#!/bin/sh
set -e

_switch_github_account() {
    case "$1" in
        "sub0xdai")
            echo "Switching to sub0xdai account..."
            # Set git configuration first
            export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_github_sub0xdai"
            git config user.name "sub0xdai"
            git config user.email "sub0xdai@users.noreply.github.com"
            GITHUB_USER="sub0xdai"
            # Ensure GitHub CLI uses SSH
            gh config set git_protocol ssh
            ;;
        *)
            echo "Switching to tehuticode account..."
            # Set git configuration first
            export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519"
            git config user.name "tehuticode"
            git config user.email "tehuticode@users.noreply.github.com"
            GITHUB_USER="tehuticode"
            # Ensure GitHub CLI uses SSH
            gh config set git_protocol ssh
            ;;
    esac

    # Verify we can access GitHub
    if ! gh auth status 2>/dev/null; then
        echo "Error: GitHub CLI authentication failed for $GITHUB_USER"
        echo "Please run: gh auth login"
        exit 1
    fi
}

_make_new_gh_repo() {
    local repo_visibility=""
    local commit_message="Initial commit: Add README"
    
    # Get repository visibility
    while true; do
        read -p "Should the repository be public? (y/n): " visibility_choice
        case "$visibility_choice" in
            [Yy]* ) repo_visibility="public"; break;;
            [Nn]* ) repo_visibility="private"; break;;
            * ) echo "Please answer y/n.";;
        esac
    done

    # Get repository name from current directory
    repo_name=$(basename "$PWD")
    echo "Using current directory name as repository name: $repo_name"

    # Get GitHub account choice
    echo "Which GitHub account do you want to use?"
    echo "1) tehuticode (default)"
    echo "2) sub0xdai"
    read -p "Select account (1/2): " account_choice

    # Switch GitHub account based on choice
    case "$account_choice" in
        2) _switch_github_account "sub0xdai" ;;
        *) _switch_github_account "tehuticode" ;;
    esac

    # Initialize git repository if needed
    if [ ! -d ".git" ]; then
        git init
        # Create README and make initial commit
        echo "# $repo_name" > README.md
        git add README.md
        git commit -m "$commit_message" --no-verify
    fi

    # Configure git user for this repository
    git config user.name "$GITHUB_USER"
    git config user.email "${GITHUB_USER}@users.noreply.github.com"

    # Remove existing origin if it exists
    git remote remove origin 2>/dev/null || true

    # Create repository on GitHub and set up remote
    if [ "$repo_visibility" = "private" ]; then
        gh repo create "$repo_name" --private --source=. --remote=origin --git-protocol ssh
    else
        gh repo create "$repo_name" --public --source=. --remote=origin --git-protocol ssh
    fi

    # Push changes, forcing if necessary to handle repository switch
    git push -u origin HEAD --force --no-verify
    
    echo "Repository created successfully!"
    echo "Visit: https://github.com/$GITHUB_USER/$repo_name"
}

_make_new_gh_repo "$@"
