#!/bin/bash

# Clear the screen
clear

# Script header
echo "===================================================="
echo "         Comprehensive System Information"
echo "===================================================="
echo "Script executed on: $(date)"
echo

# User and Login Information
echo "==== USER & LOGIN INFORMATION ===="
echo "Logged in User: ${USER^}"
echo "Home Directory: $HOME"
echo "Current Shell: $SHELL"
echo "Login Shell: $(ps -p $$ | tail -1 | awk '{print $4}')"
echo

# System Information
echo "==== SYSTEM DETAILS ===="
echo "Hostname: $(hostname)"
echo "Operating System: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "System Uptime: $(uptime -p)"
echo

# Hardware Information
echo "==== HARDWARE OVERVIEW ===="
# CPU Information
echo "CPU Details:"
cat /proc/cpuinfo | grep "model name" | head -1 | cut -d ':' -f 2
echo "CPU Cores: $(nproc)"
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4"%"}')"
echo

# Memory Information
echo "==== MEMORY DETAILS ===="
free -h | sed -n '1,2p'  # Total and used memory
echo "Memory Usage: $(free | grep Mem | awk '{printf "%.2f%%", $3/$2 * 100.0}')"
echo

# Disk Information
echo "==== DISK USAGE ===="
df -h | grep '^/dev' | awk '{print $1 " - Total: " $2 " Used: " $3 " (" $5 " Capacity)"}'
echo

# Network Information
echo "==== NETWORK DETAILS ===="
echo "Hostname: $(hostname)"
ip addr | grep -E '^[0-9]+:' | cut -d: -f2 | while read -r interface; do
    echo -n "$interface: "
    ip addr show "$interface" | grep inet\ | awk '{print $2}' | head -1
done
echo "External IP: $(curl -s ifconfig.me 2>/dev/null || echo "Unable to retrieve")"
echo

# Currently Connected Users
echo "==== CONNECTED USERS ===="
w | grep -v "USER" | awk '{print $1, $2, $3}'
echo

# Running Processes
echo "==== TOP 10 RESOURCE-INTENSIVE PROCESSES ===="
ps aux | sort -nrk 3,3 | head -10 | awk '{print $2, $3, $4, $11}'
echo

# System Load
echo "==== SYSTEM LOAD ===="
uptime
echo

# Closing message
echo "===================================================="
echo "           System Overview Complete!"
