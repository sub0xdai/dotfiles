#!/bin/bash
# Update all mise tools to their latest versions and bump the config.
# `mise upgrade --bump` installs the latest available version for each tool
# and updates ~/.config/mise/config.toml with the new version.

set -euo pipefail

if ! command -v mise &> /dev/null; then
    echo "mise is not installed. Install it first: https://mise.jdx.dev"
    exit 1
fi

update_tools() {
    if [[ "${1:-}" == "--dry-run" ]]; then
        echo "=== Dry run: tools that would be upgraded ==="
        mise outdated
        echo
        mise upgrade --dry-run --bump
    else
        echo "=== Currently outdated ==="
        mise outdated || true
        echo
        echo "=== Upgrading all tools ==="
        mise upgrade --bump --yes
        echo
        echo "=== After upgrade ==="
        mise ls
    fi
}

# Ensure the script only runs the function if it's executed directly, not sourced.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    update_tools "$@"
fi


