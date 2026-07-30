#!/bin/bash
# Wireshark launcher with automatic X11 permission handling
#
# Usage: run-wireshark.sh [--sudo|-s] [--pull|-p]
#   --sudo, -s   Run with --privileged (for interfaces needing extra caps)
#   --pull, -p   Force pull fresh image

set -euo pipefail

# --- Prerequisites ---
command -v podman >/dev/null 2>&1 || { echo "ERROR: podman not found"; exit 1; }
command -v xhost >/dev/null 2>&1 || { echo "ERROR: xhost not found"; exit 1; }
[ -n "${DISPLAY:-}" ] || { echo "ERROR: DISPLAY not set (no X11 session?)"; exit 1; }

# --- Flags ---
PRIVILEGED=""
FORCE_PULL=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --sudo|-s)  PRIVILEGED="--privileged" ;;
        --pull|-p)  FORCE_PULL="yes" ;;
        -h|--help)  echo "Usage: $0 [--sudo|-s] [--pull|-p]"; exit 0 ;;
        *)          echo "Unknown flag: $1"; exit 1 ;;
    esac
    shift
done

# X11: use host-based auth because cookie auth doesn't work with this
# Xorg/lightdm setup (server uses -auth /run/lightdm/root/:0).
# +local: is scoped to local non-network connections only.
ORIG_XHOST=$(xhost 2>/dev/null || true)

cleanup() {
    echo "Restoring X11 permissions..."
    if ! echo "$ORIG_XHOST" | grep -q "LOCAL:"; then
        xhost -local: >/dev/null 2>&1 || true
    fi
    exit
}
trap cleanup INT TERM EXIT

echo "Setting X11 permissions..."
xhost +local: >/dev/null 2>&1

# --- Image management ---
if [ "$FORCE_PULL" = "yes" ] || ! podman image exists docker.io/jess/wireshark; then
    echo "Pulling Wireshark image..."
    podman pull docker.io/jess/wireshark
fi

# --- Container cleanup ---
if podman ps -a --format "{{.Names}}" | grep -q "^wireshark$"; then
    echo "Removing existing Wireshark container..."
    podman rm -f wireshark >/dev/null 2>&1
fi

mkdir -p "$HOME/wireshark_captures"

echo "Starting Wireshark..."
# shellcheck disable=SC2086
podman run -it --rm \
    --net=host \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$HOME/wireshark_captures:/captures" \
    --name wireshark \
    $PRIVILEGED \
    docker.io/jess/wireshark
