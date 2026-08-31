#!/usr/bin/env bash
# Bootstrap an scythe video project scaffold at the given directory.
# Usage: scythe_bootstrap.sh <target-dir>
#
# Copies the template directory (audio/, prompts/, raw_footage/, overlays/,
# output/, config.json, README.md) from scythe into <target-dir>.
set -euo pipefail

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
    echo "Usage: scythe_bootstrap.sh <target-dir>"
    echo "  Creates an scythe video project scaffold at <target-dir>"
    exit 1
fi

if [ -d "$TARGET" ]; then
    echo "Error: $TARGET already exists"
    exit 1
fi

SCYTHE_HOME="$HOME/1-projects/scythe"
TEMPLATE="$SCYTHE_HOME/templates/project"

cp -r "$TEMPLATE" "$TARGET"
echo "✓ Bootstrapped scythe project at $TARGET"
echo "  → drop audio in $(basename "$TARGET")/audio/"
echo "  → drop footage in $(basename "$TARGET")/raw_footage/"
echo "  → drop overlays in $(basename "$TARGET")/overlays/"
