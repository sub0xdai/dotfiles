#!/usr/bin/env bash
# Bootstrap an n0x-content video project scaffold at the given directory.
# Usage: n0x_bootstrap.sh <target-dir>
#
# Copies the template directory (audio/, prompts/, raw_footage/, overlays/,
# output/, config.json, README.md) from n0x-content into <target-dir>.
set -euo pipefail

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
    echo "Usage: n0x_bootstrap.sh <target-dir>"
    echo "  Creates an n0x-content video project scaffold at <target-dir>"
    exit 1
fi

if [ -d "$TARGET" ]; then
    echo "Error: $TARGET already exists"
    exit 1
fi

N0X_CONTENT="$HOME/1-projects/n0x-content"
TEMPLATE="$N0X_CONTENT/templates/project"

cp -r "$TEMPLATE" "$TARGET"
echo "✓ Bootstrapped n0x-content project at $TARGET"
echo "  → drop audio in $(basename "$TARGET")/audio/"
echo "  → drop footage in $(basename "$TARGET")/raw_footage/"
echo "  → drop overlays in $(basename "$TARGET")/overlays/"
