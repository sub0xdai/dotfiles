#!/usr/bin/env bash
# Ensure the n0x-content podman container image is built.
# Idempotent — safe to run repeatedly (podman build uses layer caching).
set -euo pipefail

N0X_CONTENT="$HOME/1-projects/n0x-content"

if ! podman image exists kinetic-renderer &>/dev/null; then
    echo "=== Building n0x-content container image (first run) ==="
    cd "$N0X_CONTENT"
    podman build -t kinetic-renderer .
    echo "=== Container ready ==="
else
    echo "=== Container image already exists (kinetic-renderer) ==="
fi
