#!/bin/bash
# Wireshark launcher with automatic X11 permission handling

# Function to clean up X11 permissions even if the script is interrupted
cleanup() {
    echo "Cleaning up X11 permissions..."
    xhost -local: >/dev/null 2>&1
    exit
}

# Set up trap to ensure cleanup happens even if script is interrupted
trap cleanup INT TERM EXIT

# Allow X server connection from local users
echo "Setting X11 permissions..."
xhost +local: >/dev/null 2>&1

# Check if the image exists, if not pull it
if ! podman image exists docker.io/jess/wireshark; then
    echo "Pulling Wireshark image..."
    podman pull docker.io/jess/wireshark
fi

# Check if container exists and is running
if podman ps -a --format "{{.Names}}" | grep -q "^wireshark$"; then
    echo "Removing existing Wireshark container..."
    # If container exists, remove it to ensure we start fresh
    podman rm -f wireshark >/dev/null 2>&1
fi

# Create captures directory if it doesn't exist
mkdir -p $HOME/wireshark_captures

# Run wireshark with proper X11 forwarding
echo "Starting Wireshark..."
podman run -it --rm \
    --net=host \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/wireshark_captures:/captures \
    --security-opt label=disable \
    --name wireshark \
    docker.io/jess/wireshark

# Cleanup is handled by the trap
