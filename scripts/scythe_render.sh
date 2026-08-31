#!/usr/bin/env bash
# Render an scythe video project.
# Usage: scythe_render.sh <project-dir> [options...]
#
# Builds the podman container if needed, then renders.
# Options: --resolution WxH, --font NAME, --font-size N, --audio-offset S
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PROJECT="${1:-}"
if [ -z "$PROJECT" ]; then
    echo "Usage: scythe_render.sh <project-dir> [options]"
    echo "  --resolution WxH     Override resolution (e.g. 1920x1080)"
    echo "  --font NAME          Override font"
    echo "  --font-size N        Override font size"
    echo "  --audio-offset S     Start N seconds into audio"
    exit 1
fi

# Ensure container is built
"$SCRIPT_DIR/scythe_build.sh"

SCYTHE_HOME="$HOME/1-projects/scythe"

# Delegate to scythe render.sh with all args
cd "$SCYTHE_HOME"
exec podman run --rm -v "$(pwd):/app:Z" -v "$PROJECT:$PROJECT:Z" scythe --project "$PROJECT" "${@:2}"
