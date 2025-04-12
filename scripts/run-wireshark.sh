#!/bin/bash
# Check if container exists and is running
if podman ps -a --format "{{.Names}}" | grep -q "^wireshark$"; then
  # If container exists, remove it to ensure we start fresh
  podman rm -f wireshark >/dev/null 2>&1
fi

# Run wireshark with proper X11 forwarding
podman run -it --rm \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/wireshark_captures:/captures \
  --name wireshark \
  docker.io/jess/wireshark
