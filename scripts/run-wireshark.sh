#!/bin/bash
# Wireshark launcher with automatic X11 permission handling

cleanup() {
    echo "Cleaning up X11 permissions..."
    xhost -local: >/dev/null 2>&1
    exit
}

trap cleanup INT TERM EXIT

echo "Setting X11 permissions..."
xhost +local: >/dev/null 2>&1

if ! podman image exists docker.io/jess/wireshark; then
    echo "Pulling Wireshark image..."
    podman pull docker.io/jess/wireshark
fi

if podman ps -a --format "{{.Names}}" | grep -q "^wireshark$"; then
    echo "Removing existing Wireshark container..."
    podman rm -f wireshark >/dev/null 2>&1
fi

mkdir -p $HOME/wireshark_captures

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

