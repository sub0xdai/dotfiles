#!/usr/bin/env bash
# Render an n0x-content video project.
# Usage: n0x_render.sh <project-dir> [options...]
#
# Builds the podman container if needed, then renders.
# Options: --resolution WxH, --font NAME, --font-size N, --audio-offset S
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PROJECT="${1:-}"
if [ -z "$PROJECT" ]; then
    echo "Usage: n0x_render.sh <project-dir> [options]"
    echo "  --resolution WxH     Override resolution (e.g. 1920x1080)"
    echo "  --font NAME          Override font"
    echo "  --font-size N        Override font size"
    echo "  --audio-offset S     Start N seconds into audio"
    exit 1
fi

# Ensure container is built
"$SCRIPT_DIR/n0x_build.sh"

N0X_CONTENT="$HOME/1-projects/n0x-content"

# Delegate to n0x-content render.sh with all args
cd "$N0X_CONTENT"
exec podman run --rm -v "$(pwd):/app:Z" kinetic-renderer --project "$PROJECT" "${@:2}"
