#!/bin/bash

# Multi-Distribution Log Analysis Script
# Supports: Arch Linux (systemd), Ubuntu/Debian, Rocky/RHEL/CentOS
# Author: Sub0x Enhanced Version
# Purpose: Automated threat detection and incident response log analysis

set -euo pipefail

# Configuration
REPORT_FILE="/tmp/security_analysis_$(date +%Y%m%d_%H%M%S).txt"
ALERT_THRESHOLD=10
CRITICAL_THRESHOLD=5
EMAIL_ALERT="admin@company.com"
HOURS_BACK=24

# Enhanced pattern arrays with severity classification
declare -A SEVERITY_PATTERNS=(
    ["CRITICAL"]="CRITICAL|FATAL|PANIC|SEGFAULT|KERNEL PANIC|systemd.*failed|Failed to start"
    ["ERROR"]="ERROR|FAIL|EXCEPTION|DENIED|REFUSED|TIMEOUT|authentication failure|connection refused"
    ["WARNING"]="WARNING|WARN|SUSPICIOUS|ANOMALY|UNUSUAL|deprecated"
    ["SECURITY"]="AUTHENTICATION FAILED|UNAUTHORIZED|INTRUSION|MALWARE|VIRUS|EXPLOIT|sudo.*COMMAND|Failed password|Invalid user"
)

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Distribution detection
detect_distribution() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$REPORT_FILE"
}

# Alert function
send_alert() {
    local severity=$1
    local message=$2
    local count=$3
    
    echo -e "${RED}🚨 ALERT: ${severity} - ${message} (Count: ${count})${NC}"
    
    if command -v mail &> /dev/null; then
        echo "Security Alert: $severity - $message (Count: $count)" | \
        mail -s "Security Alert: $severity Events Detected" "$EMAIL_ALERT"
    fi
}

# Systemd journal analysis (Arch, newer Ubuntu/Rocky)
analyze_systemd_journal() {
    local severity=$1
    local pattern=$2
    local count=0
    
    if command -v journalctl &> /dev/null; then
        # Get journal entries from last N hours
        local journal_data=$(journalctl --since "${HOURS_BACK} hours ago" --no-pager 2>/dev/null)
        
        if [[ -n "$journal_data" ]]; then
            count=$(echo "$journal_data" | grep -cEi "$pattern" 2>/dev/null || echo 0)
            
            if [[ $count -gt 0 ]]; then
                echo -e "${BLUE}$severity Events (systemd): $count${NC}" >&2
                echo -e "${YELLOW}Recent $severity entries from journal:${NC}" >&2
                echo "$journal_data" | grep -Ei "$pattern" | tail -n 5 | \
                while read -r line; do
                    echo "  $line" >&2
                done
                echo "" >&2
            fi
        fi
    fi
    
    echo "$count"
}

# Traditional log file analysis
analyze_traditional_logs() {
    local severity=$1
    local pattern=$2
    local log_files=()
    local total_count=0
    
    # Distribution-specific log paths
    local distro=$(detect_distribution)
    
    case "$distro" in
        "arch")
            log_files=(
                "/var/log/pacman.log"
                "/var/log/Xorg.0.log"
                "/var/log/Xorg.1.log"
                "/var/log/errors.log"
            )
            ;;
        "ubuntu"|"debian")
            log_files=(
                "/var/log/syslog"
                "/var/log/auth.log"
                "/var/log/kern.log"
                "/var/log/dpkg.log"
                "/var/log/apt/history.log"
                "/var/log/apache2/error.log"
                "/var/log/nginx/error.log"
            )
            ;;
        "rocky"|"rhel"|"centos"|"fedora")
            log_files=(
                "/var/log/messages"
                "/var/log/secure"
                "/var/log/maillog"
                "/var/log/cron"
                "/var/log/httpd/error_log"
                "/var/log/nginx/error.log"
                "/var/log/yum.log"
                "/var/log/dnf.log"
            )
            ;;
        *)
            # Generic fallback
            log_files=(
                "/var/log/messages"
                "/var/log/syslog"
                "/var/log/auth.log"
                "/var/log/secure"
            )
            ;;
    esac
    
    # Add common log files
    log_files+=(
        "/var/log/dmesg"
        "/var/log/boot.log"
        "/var/log/lastlog"
    )
    
    # Find additional .log files modified in last 24 hours
    if [[ -d "/var/log" ]]; then
        while IFS= read -r -d '' file; do
            log_files+=("$file")
        done < <(find /var/log -type f -name "*.log" -mtime -1 -print0 2>/dev/null)
    fi
    
    # Analyze each log file
    for log_file in "${log_files[@]}"; do
        if [[ -r "$log_file" && -s "$log_file" ]]; then
            # Check modification time
            if find "$log_file" -mtime -1 2>/dev/null | grep -q .; then
                local count=$(grep -cEi "$pattern" "$log_file" 2>/dev/null || echo 0)
                
                if [[ $count -gt 0 ]]; then
                    echo -e "${BLUE}$severity Events in $(basename "$log_file"): $count${NC}" >&2
                    echo -e "${YELLOW}Recent $severity entries:${NC}" >&2
                    grep -Ei "$pattern" "$log_file" 2>/dev/null | tail -n 3 | \
                    while read -r line; do
                        echo "  $line" >&2
                    done
                    echo "" >&2
                    
                    total_count=$((total_count + count))
                fi
            fi
        fi
    done
    
    printf "%d" "$total_count"
}

# Enhanced analysis function
analyze_logs() {
    local total_events=0
    local critical_events=0
    local distro=$(detect_distribution)
    
    log_message "Detected distribution: $distro"
    log_message "Starting comprehensive log analysis"
    
    # Analyze each severity pattern
    for severity in "${!SEVERITY_PATTERNS[@]}"; do
        local pattern="${SEVERITY_PATTERNS[$severity]}"
        local systemd_count=0
        local traditional_count=0
        
        echo -e "${GREEN}Analyzing $severity patterns...${NC}"
        
        # Try systemd journal first (modern systems)
        systemd_count=$(analyze_systemd_journal "$severity" "$pattern")
        
        # Then traditional log files
        traditional_count=$(analyze_traditional_logs "$severity" "$pattern")
        
        local total_pattern_count=$((systemd_count + traditional_count))
        
        if [[ $total_pattern_count -gt 0 ]]; then
            log_message "$severity total events: $total_pattern_count (systemd: $systemd_count, files: $traditional_count)"
            
            total_events=$((total_events + total_pattern_count))
            
            # Critical severity tracking
            if [[ "$severity" == "CRITICAL" || "$severity" == "SECURITY" ]]; then
                critical_events=$((critical_events + total_pattern_count))
            fi
            
            # Threshold-based alerting
            if [[ $total_pattern_count -gt $ALERT_THRESHOLD ]]; then
                send_alert "$severity" "High event count detected" "$total_pattern_count"
            fi
        fi
        
        echo -e "${GREEN}----------------------------------------${NC}"
    done
    
    # Final summary
    log_message "Analysis Summary - Total: $total_events, Critical: $critical_events"
    
    if [[ $critical_events -gt $CRITICAL_THRESHOLD ]]; then
        send_alert "CRITICAL" "Critical event threshold exceeded" "$critical_events"
    fi
}

# System information gathering
gather_system_info() {
    local distro=$(detect_distribution)
    
    log_message "System Information:"
    log_message "Distribution: $distro"
    log_message "Kernel: $(uname -r)"
    log_message "Uptime: $(uptime -p 2>/dev/null || uptime)"
    
    # Check if systemd is available
    if command -v systemctl &> /dev/null; then
        log_message "Systemd available: Yes"
        local failed_services=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
        log_message "Failed services: $failed_services"
    else
        log_message "Systemd available: No"
    fi
    
    # Check available log sources
    local log_sources=()
    [[ -r "/var/log/syslog" ]] && log_sources+=("syslog")
    [[ -r "/var/log/messages" ]] && log_sources+=("messages")
    [[ -r "/var/log/auth.log" ]] && log_sources+=("auth.log")
    [[ -r "/var/log/secure" ]] && log_sources+=("secure")
    command -v journalctl &> /dev/null && log_sources+=("journalctl")
    
    log_message "Available log sources: ${log_sources[*]}"
}

# Main execution
main() {
    echo -e "${BLUE}🔍 Multi-Distribution Security Log Analysis${NC}"
    echo -e "${BLUE}===========================================${NC}"
    
    # Initialize report
    log_message "Starting multi-distribution log analysis"
    log_message "Configuration: ALERT_THRESHOLD=$ALERT_THRESHOLD, HOURS_BACK=$HOURS_BACK"
    
    # Gather system information
    gather_system_info
    
    # Check permissions
    if [[ $EUID -ne 0 ]]; then
        log_message "WARNING: Running as non-root user - some log files may be inaccessible"
        echo -e "${YELLOW}⚠️  Consider running with sudo for complete analysis${NC}"
    fi
    
    # Perform analysis
    analyze_logs
    
    # Final summary
    log_message "Analysis completed. Report saved to: $REPORT_FILE"
    echo -e "${GREEN}✅ Analysis complete. Report: $REPORT_FILE${NC}"
    
    # Display quick stats
    if [[ -f "$REPORT_FILE" ]]; then
        local total_lines=$(wc -l < "$REPORT_FILE")
        local event_lines=$(grep -c "total events:" "$REPORT_FILE" 2>/dev/null || echo 0)
        echo -e "${BLUE}Report Statistics:${NC}"
        echo "Total log entries: $total_lines"
        echo "Event categories analyzed: $event_lines"
        echo "Report location: $REPORT_FILE"
    fi
}

# Cleanup function
cleanup() {
    log_message "Script execution completed"
}

# Signal handling
trap cleanup EXIT INT TERM

# Execute main function
main "$@"
