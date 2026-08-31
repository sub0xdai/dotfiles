#!/usr/bin/env bash
# Ensure the scythe podman container image is built.
# Idempotent — safe to run repeatedly (podman build uses layer caching).
set -euo pipefail

SCYTHE_HOME="$HOME/1-projects/scythe"

if ! podman image exists scythe &>/dev/null; then
    echo "=== Building scythe container image (first run) ==="
    cd "$SCYTHE_HOME"
    podman build -t scythe .
    echo "=== Container ready ==="
else
    echo "=== Container image already exists (scythe) ==="
fi
