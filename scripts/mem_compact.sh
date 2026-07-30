#!/usr/bin/env bash 

set -euo pipefail 

if [[ $EUID -ne 0 ]]; then 
  echo "Error: Run as root" >&2
  exit 1
fi 

sync 

echo 3 > /proc/sys/vm/drop_caches 
echo 1 > /proc/sys/vm/compact_memory 
echo "Memory compacted successfully"

