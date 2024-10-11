#!/bin/sh
set -e -x 

_make_new_gh_repo() {
    local repo_visibility="private"
    local commit_message="Initial commit: Add README"
    
    # Parse options
    while getopts "pm:" opt; do
        case $opt in
            p) repo_visibility="public" ;;
            m) commit_message="$OPTARG" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    local repo_name="$1"
    if test -n "$repo_name" ; then
        mkdir -p "$repo_name"
        cd "$repo_name"
    fi 

    if ! test -d './.git' ; then
        git init
    fi 
    
    if [ -z "$(git status --porcelain)" ]; then
        # Create a dummy file if the directory is empty
        echo "# Project Description" > README.md
        git add README.md
    else
        git add .
    fi

    git commit -m "$commit_message" --no-verify
    
    gh repo create --source . --remote origin --"$repo_visibility" || true
    git push -u origin HEAD --no-verify
    git status
}

_make_new_gh_repo "$@"
