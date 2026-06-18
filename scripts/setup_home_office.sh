##!/bin/bash
set -e

# Function to install common development tools
install_dev_tools() {
    echo "Installing development tools..."
    if command -v dnf &> /dev/null; then
        dnf update -y
        dnf groupinstall -y "Development Tools"
        dnf install -y git vim nodejs npm python3 python3-pip
    elif command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y build-essential git vim nodejs npm python3 python3-pip
    else
        echo "Unsupported package manager. Please install development tools manually."
        exit 1
    fi
}

# Function to set up a basic firewall
setup_firewall() {
    echo "Setting up firewall..."
    if command -v ufw &> /dev/null; then
        ufw allow 22/tcp  # SSH
        ufw allow 80/tcp  # HTTP
        ufw allow 443/tcp # HTTPS
        ufw enable
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --zone=public --add-service=ssh --permanent
        firewall-cmd --zone=public --add-service=http --permanent
        firewall-cmd --zone=public --add-service=https --permanent
        firewall-cmd --reload
    else
        echo "No supported firewall found. Please configure firewall manually."
    fi
}

# Function to create a backup script
create_backup_script() {
    echo "Creating backup script..."
    cat <<EOF > /usr/local/bin/backup.sh
#!/bin/bash
backup_dir="/home/backups/\$(date +%Y-%m-%d)"
mkdir -p "\$backup_dir"
tar -czf "\$backup_dir/home_backup.tar.gz" /home
echo "Backup completed: \$backup_dir/home_backup.tar.gz"
EOF
    chmod +x /usr/local/bin/backup.sh
    echo "0 1 * * * root /usr/local/bin/backup.sh" > /etc/cron.d/daily_backup
}

# Function to set up a simple monitoring script
setup_monitoring() {
    echo "Setting up system monitoring..."
    cat <<EOF > /usr/local/bin/monitor.sh
#!/bin/bash
echo "System Monitor Report ($(date))"
echo "-------------------------------"
echo "Disk Usage:"
df -h
echo "-------------------------------"
echo "Memory Usage:"
free -h
echo "-------------------------------"
echo "Top 5 CPU-consuming processes:"
ps aux --sort=-%cpu | head -n 6
EOF
    chmod +x /usr/local/bin/monitor.sh
    echo "0 * * * * root /usr/local/bin/monitor.sh > /var/log/system_monitor.log" > /etc/cron.d/hourly_monitor
}

# Main execution
main() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    fi
    
    install_dev_tools
    setup_firewall
    create_backup_script
    setup_monitoring
    echo "All tasks completed. Your development environment is ready!"
}

main "$@"
