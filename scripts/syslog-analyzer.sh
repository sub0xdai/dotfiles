#!/bin/bash

# System Diagnostics and Fix Tool for Arch Linux
# Combines interactive fixes with comprehensive log analysis

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Global variables
ROOT_PASSWORD=""
TEMP_DIR=""
REPORT_FILE="/tmp/system_analysis_$(date +%Y%m%d_%H%M%S).txt"

# Function to prompt for root password
prompt_for_root_password() {
    if [[ -z "$ROOT_PASSWORD" ]]; then
        read -rsp "Root password: " ROOT_PASSWORD
        echo ""
    fi
}

# Cleanup function
cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Initialize temporary directory
init_temp_dir() {
    TEMP_DIR=$(mktemp -d -t arch_diagnostic.XXXXXX)
    chmod 700 "$TEMP_DIR"
}

# Function to run commands with sudo
run_as_root() {
    local cmd="$1"
    echo "$ROOT_PASSWORD" | sudo -S bash -c "$cmd"
}

# Function to analyze system logs (simplified version)
analyze_system_logs() {
    clear
    echo -e "${BOLD}Analyzing System Logs...${NC}\n"
    
    # Create report file
    {
        echo "System Log Analysis Report"
        echo "Generated: $(date)"
        echo "----------------------------------------"
    } > "$REPORT_FILE"
    
    # Check for recent errors
    echo -e "${YELLOW}Checking for recent system errors...${NC}"
    run_as_root "journalctl -p 3 -xb --no-pager | tail -50" >> "$REPORT_FILE"
    
    # Check for kernel issues
    echo -e "${YELLOW}Checking for kernel issues...${NC}"
    run_as_root "dmesg | grep -iE 'error|fail|panic|warning' | tail -30" >> "$REPORT_FILE"
    
    # Check failed services
    echo -e "${YELLOW}Checking for failed services...${NC}"
    run_as_root "systemctl --failed --no-pager" >> "$REPORT_FILE"
    
    # Check disk space
    echo -e "${YELLOW}Checking disk space...${NC}"
    df -h | grep -vE "tmpfs|devtmpfs" >> "$REPORT_FILE"
    
    # Check memory usage
    echo -e "${YELLOW}Checking memory usage...${NC}"
    free -h >> "$REPORT_FILE"
    
    echo -e "\n${GREEN}Analysis complete! Report saved to: $REPORT_FILE${NC}"
    echo -e "\nWould you like to view the report? (y/n): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        less "$REPORT_FILE"
    fi
    
    echo -e "\nPress Enter to return to the menu..."
    read
}

# Main menu function
show_menu() {
    clear
    echo -e "${BOLD}  Arch Linux Diagnostic & Repair Tool${NC}"
    echo -e "  -----------------------------------\n"
    
    local commands=(
        "Analyze System Logs"
        "Fix 'failed to synchronize all databases' (Pacman)"
        "Fix 'unable to lock database' (Pacman)"
        "Fix 'unable to lock database' (Pamac)"
        "Fix Clock Time Issues"
        "Fix Network Connectivity"
        "Fix Corrupted PGP Signatures"
        "Fix Corrupted Packages"
        "Fix DNSCrypt Issues"
        "Fix GPG Key Errors"
        "Fix Login Issues"
        "Fix Login Issues (NVIDIA)"
        "Show Live System Logs (dmesg)"
        "Update System"
        "Show Detailed Hardware Info"
        "Quit"
    )
    
    for i in "${!commands[@]}"; do
        if [ "$i" -eq "$selected" ]; then
            echo -e "${BOLD}➤ ${commands[$i]}${NC}\n"
        else
            echo -e "  ${commands[$i]}\n"
        fi
    done
}

# Execute the selected command
execute_command() {
    case $selected in
        0) # Analyze System Logs
            analyze_system_logs
            ;;
        1) # Fix Pacman database sync
            clear
            echo -e "${YELLOW}Fixing 'failed to synchronize all databases' error...${NC}"
            run_as_root 'rm -rf /var/lib/pacman/sync && rm -rf /var/tmp/pamac/dbs/sync && pacman -Sy'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        2) # Fix Pacman lock
            clear
            echo -e "${YELLOW}Removing Pacman database lock...${NC}"
            run_as_root 'rm -f /var/lib/pacman/db.lck'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        3) # Fix Pamac lock
            clear
            echo -e "${YELLOW}Removing Pamac database lock...${NC}"
            run_as_root 'rm -f /var/tmp/pamac/dbs/db.lck'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        4) # Fix clock time
            clear
            echo -e "${YELLOW}Synchronizing system clock...${NC}"
            run_as_root 'timedatectl set-ntp true'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        5) # Fix connectivity
            clear
            echo -e "${YELLOW}Resetting NetworkManager...${NC}"
            echo -e "${RED}Warning: This will reboot your system!${NC}"
            echo -e "Continue? (y/n): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                run_as_root 'systemctl stop NetworkManager && rm -rf /etc/NetworkManager/system-connections/* && systemctl start NetworkManager'
            fi
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        6) # Fix PGP signatures
            clear
            echo -e "${YELLOW}Refreshing PGP keys...${NC}"
            run_as_root 'pacman-key --refresh-keys'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        7) # Fix corrupted packages
            clear
            echo -e "${YELLOW}Reinstalling all packages...${NC}"
            echo -e "${RED}Warning: This may take a while!${NC}"
            echo -e "Continue? (y/n): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                run_as_root 'pacman -Qnq | pacman -S --noconfirm -'
            fi
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        8) # Fix DNSCrypt
            clear
            echo -e "${YELLOW}Fixing DNSCrypt...${NC}"
            run_as_root 'systemctl stop dnscrypt-proxy && systemctl start dnscrypt-proxy'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        9) # Fix GPG keys
            clear
            echo -e "${YELLOW}Resetting GPG keys...${NC}"
            run_as_root 'rm -rf /etc/pacman.d/gnupg && pacman-key --init && pacman-key --populate archlinux'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        10) # Fix login issues
            clear
            echo -e "${YELLOW}Fixing login issues...${NC}"
            echo -e "${RED}Warning: This will update GRUB and reinstall kernel!${NC}"
            echo -e "Continue? (y/n): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                run_as_root 'pacman -S linux linux-headers --noconfirm && grub-mkconfig -o /boot/grub/grub.cfg'
            fi
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        11) # Fix NVIDIA login issues
            clear
            echo -e "${YELLOW}Fixing NVIDIA login issues...${NC}"
            echo -e "${RED}Warning: This will reinstall NVIDIA drivers and kernel!${NC}"
            echo -e "Continue? (y/n): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                run_as_root 'pacman -S nvidia nvidia-utils linux linux-headers --noconfirm && grub-mkconfig -o /boot/grub/grub.cfg'
            fi
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        12) # Show dmesg
            clear
            run_as_root 'dmesg | tail -50'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        13) # Update system
            clear
            echo -e "${YELLOW}Updating system...${NC}"
            run_as_root 'pacman -Syu --noconfirm'
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        14) # Show hardware info
            clear
            echo -e "${BOLD}Hardware Information:${NC}\n"
            echo -e "${YELLOW}CPU:${NC}"
            lscpu | grep "Model name"
            echo -e "\n${YELLOW}Memory:${NC}"
            free -h
            echo -e "\n${YELLOW}Disk:${NC}"
            lsblk
            echo -e "\n${YELLOW}Graphics:${NC}"
            lspci | grep -i vga
            echo -e "\nPress Enter to return to the menu..."
            read
            ;;
        15) # Quit
            exit 0
            ;;
    esac
}

# Main script
main() {
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        echo "Please run as normal user. The script will ask for root password when needed."
        exit 1
    fi
    
    # Initialize
    init_temp_dir
    prompt_for_root_password
    
    # Main loop
    selected=0
    while true; do
        show_menu
        
        # Get user input
        read -rsn1 key
        
        case "$key" in
            $'\x1b') # ESC sequence
                read -rsn2 -t 0.1 key
                case "$key" in
                    '[A') # Up arrow
                        ((selected--))
                        if [ $selected -lt 0 ]; then
                            selected=15
                        fi
                        ;;
                    '[B') # Down arrow
                        ((selected++))
                        if [ $selected -gt 15 ]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '') # Enter key
                execute_command
                ;;
        esac
    done
}

# Run main
main "$@"
