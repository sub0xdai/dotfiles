#!/bin/bash
# Get the current date in YYYYMMDD format
current_date=$(date +%Y%m%d)

# Run pacman -Q and save the output to a file with the current date
pacman -Q > "${current_date}_installed.txt"

