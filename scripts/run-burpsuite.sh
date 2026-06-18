#!/bin/bash
podman run --rm \
  -v "/tmp/.X11-unix:/tmp/.X11-unix" \
  -e "DISPLAY=$DISPLAY" \
  -p 8080:8080 \
  -v "$HOME/burp_data:/home/burp/project" \
  --name burp-suite docker.io/hexcowboy/burpsuite
