#!/bin/bash

# Uninstall script for server optimizer
# This script removes the optimization settings and restores defaults

echo "Server Optimizer Uninstall Script"
echo "================================"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "This script will remove optimizations and restore default settings."
echo "Warning: This may affect server performance."
echo "Do you want to continue? (y/n)"
read -r response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo "Uninstalling server optimizations..."

# =====================
# Restore CPU settings
# =====================
echo "Restoring CPU settings..."

# Set CPU governor back to ondemand
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "ondemand" > $cpu
    done
    echo "CPU governor set to ondemand mode"
fi

# Remove CPU scheduler optimizations
if [ -f /etc/sysctl.d/99-cpu-scheduler.conf ]; then
    rm -f /etc/sysctl.d/99-cpu-scheduler.conf
    echo "Removed CPU scheduler optimizations"
fi

# =====================
# Restore Memory settings
# =====================
echo "Restoring memory settings..."

# Remove memory optimizations
if [ -f /etc/sysctl.d/99-memory.conf ]; then
    rm -f /etc/sysctl.d/99-memory.conf
    echo "Removed memory optimizations"
fi

# Enable transparent hugepages
echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag
echo "Enabled transparent hugepages"

# Remove from rc.local
if [ -f /etc/rc.local ]; then
    sed -i '/transparent_hugepage\/enabled/d' /etc/rc.local
    sed -i '/transparent_hugepage\/defrag/d' /etc/rc.local
    echo "Removed transparent hugepage settings from rc.local"
fi

# =====================
# Restore Network settings
# =====================
echo "Restoring network settings..."

# Remove BBR congestion control
if [ -f /etc/sysctl.d/99-network-bbr.conf ]; then
    rm -f /etc/sysctl.d/99-network-bbr.conf
    echo "Removed BBR congestion control settings"
fi

# Remove network performance settings
if [ -f /etc/sysctl.d/99-network-performance.conf ]; then
    rm -f /etc/sysctl.d/99-network-performance.conf
    echo "Removed network performance settings"
fi

# =====================
# Restore SSH settings
# =====================
echo "Restoring SSH settings..."

# Restore SSH config from backup if it exists
if [ -f /etc/ssh/sshd_config.bak ]; then
    cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
    echo "Restored original SSH configuration"
else
    # Remove our additions from SSH config
    sed -i '/# SSH Tunnel Optimization/,/UseDNS no/d' /etc/ssh/sshd_config
    echo "Removed SSH optimizations from configuration"
fi

# Restart SSH service
systemctl restart sshd
echo "Restarted SSH service"

# =====================
# Remove Process Priority management
# =====================
echo "Removing process priority management..."

# Remove SSH priority script
if [ -f /usr/local/bin/ssh-priority.sh ]; then
    rm -f /usr/local/bin/ssh-priority.sh
    echo "Removed SSH priority script"
fi

# Remove from crontab
crontab -l | grep -v "ssh-priority.sh" | crontab -
echo "Removed SSH priority from crontab"

# =====================
# Remove Anti-throttling measures
# =====================
echo "Removing anti-throttling measures..."

# Stop and disable anti-throttle service
if systemctl is-active --quiet anti-throttle.service; then
    systemctl stop anti-throttle.service
    systemctl disable anti-throttle.service
    echo "Stopped and disabled anti-throttle service"
fi

# Remove anti-throttle service file
if [ -f /etc/systemd/system/anti-throttle.service ]; then
    rm -f /etc/systemd/system/anti-throttle.service
    systemctl daemon-reload
    echo "Removed anti-throttle service file"
fi

# Remove anti-throttle script
if [ -f /usr/local/bin/anti-throttle.sh ]; then
    rm -f /usr/local/bin/anti-throttle.sh
    echo "Removed anti-throttle script"
fi

# =====================
# Remove installation files
# =====================
echo "Removing installation files..."

# Remove symlink
if [ -L /usr/local/bin/server-optimizer ]; then
    rm -f /usr/local/bin/server-optimizer
    echo "Removed server-optimizer symlink"
fi

# Remove script directory
if [ -d /opt/server-optimizer ]; then
    rm -rf /opt/server-optimizer
    echo "Removed server-optimizer directory"
fi

# =====================
# Apply changes
# =====================
echo "Applying changes..."

# Apply sysctl changes
sysctl --system

echo "Uninstallation complete!"
echo "Note: Some changes require a reboot to take full effect."
echo "It's recommended to reboot the server when possible." 