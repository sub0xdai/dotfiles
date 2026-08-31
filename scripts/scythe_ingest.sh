#!/usr/bin/env bash
# Run scythe asset ingestion for a video project.
# Usage: scythe_ingest.sh <project-dir> [--audio-query ...] [--ia-id ...] [flags]
#
# Thin wrapper — delegates to scythe/ingest.sh.
# Automatically bootstraps the project if the directory doesn't exist.
set -euo pipefail

SCYTHE_HOME="$HOME/1-projects/scythe"

PROJECT="${1:-}"
if [ -z "$PROJECT" ]; then
    echo "Usage: scythe_ingest.sh <project-dir> [options]"
    echo ""
    echo "Options (passed through to ingest.sh):"
    echo "  --audio-query STR   Search query for yt-dlp royalty-free audio"
    echo "  --ia-id STR         Internet Archive identifier for public domain video"
    echo "  --image-cat URL     Wikimedia Commons category URL"
    echo "  --no-audio          Skip audio fetching"
    echo "  --no-video          Skip video fetching"
    echo "  --no-images         Skip image scraping"
    echo "  --no-preprocess     Skip monochrome crush"
    exit 1
fi
shift

# Bootstrap if project dir doesn't exist
if [ ! -d "$PROJECT" ]; then
    echo "=== Project not found, bootstrapping ==="
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    "$SCRIPT_DIR/scythe_bootstrap.sh" "$PROJECT"
fi

exec "$SCYTHE_HOME/ingest.sh" "$PROJECT" "$@"
