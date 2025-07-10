#!/bin/bash

# Server Performance Monitoring Script
# This script monitors CPU, RAM, and network performance

echo "Server Performance Monitor"
echo "=========================="

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script should be run as root for full functionality" >&2
    echo "Some checks may not work properly"
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Install dependencies if needed
if ! command_exists bc || ! command_exists iostat || ! command_exists sysstat; then
    echo "Installing required dependencies..."
    if command_exists apt-get; then
        apt-get update && apt-get install -y bc sysstat
    elif command_exists yum; then
        yum install -y bc sysstat
    else
        echo "Warning: Could not install dependencies. Please install bc and sysstat manually."
    fi
fi

# Check CPU governor settings
echo -e "\n=== CPU Governor Settings ==="
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$(basename $(dirname $(dirname $cpu))): $(cat $cpu)"
    done
    
    # Check if all CPUs are in performance mode
    perf_count=$(grep -c "performance" /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor)
    total_cpus=$(ls -d /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | wc -l)
    
    if [ "$perf_count" -eq "$total_cpus" ]; then
        echo "✅ All CPUs are in performance mode"
    else
        echo "❌ Not all CPUs are in performance mode ($perf_count/$total_cpus)"
    fi
else
    echo "CPU frequency scaling not available"
fi

# Check sysctl settings
echo -e "\n=== System Settings ==="

# Function to check sysctl value
check_sysctl() {
    local param=$1
    local expected=$2
    local actual=$(sysctl -n $param 2>/dev/null)
    
    if [ -z "$actual" ]; then
        echo "❓ $param: Parameter not found"
        return
    fi
    
    if [ "$actual" = "$expected" ]; then
        echo "✅ $param = $actual"
    else
        echo "❌ $param = $actual (expected $expected)"
    fi
}

# Check CPU scheduler settings
echo -e "\n--- CPU Scheduler ---"
check_sysctl "kernel.sched_migration_cost_ns" "5000000"
check_sysctl "kernel.sched_autogroup_enabled" "0"

# Check memory settings
echo -e "\n--- Memory Settings ---"
check_sysctl "vm.swappiness" "10"
check_sysctl "vm.vfs_cache_pressure" "50"

# Check network settings
echo -e "\n--- Network Settings ---"
check_sysctl "net.ipv4.tcp_congestion_control" "bbr"
check_sysctl "net.core.default_qdisc" "fq"

# Check SSH settings
echo -e "\n=== SSH Configuration ==="
if [ -f /etc/ssh/sshd_config ]; then
    # Check for optimization settings
    if grep -q "ClientAliveInterval 60" /etc/ssh/sshd_config && \
       grep -q "Compression yes" /etc/ssh/sshd_config; then
        echo "✅ SSH optimizations are configured"
    else
        echo "❌ SSH optimizations are not fully configured"
    fi
else
    echo "❌ SSH config file not found"
fi

# Check anti-throttle service
echo -e "\n=== Anti-Throttle Service ==="
if systemctl is-active --quiet anti-throttle.service; then
    echo "✅ Anti-throttle service is running"
else
    echo "❌ Anti-throttle service is not running"
fi

# Monitor current performance
echo -e "\n=== Current Performance ==="

# CPU usage
echo -e "\n--- CPU Usage ---"
top -bn1 | head -n 5

# Memory usage
echo -e "\n--- Memory Usage ---"
free -m

# Load average
echo -e "\n--- Load Average ---"
uptime

# Network statistics
echo -e "\n--- Network Statistics ---"
if command_exists netstat; then
    netstat -s | grep -E "segments retransmited|connection resets received|connections established" | head -n 5
else
    echo "netstat not available"
fi

# Check for CPU throttling
echo -e "\n=== CPU Throttling Check ==="
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ] && [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq ]; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
        cur_freq=$(cat ${cpu}scaling_cur_freq)
        max_freq=$(cat ${cpu}scaling_max_freq)
        cpu_num=$(basename $(dirname $cpu))
        
        # Calculate percentage of max frequency
        percent=$(echo "scale=2; $cur_freq * 100 / $max_freq" | bc)
        
        if (( $(echo "$percent < 90" | bc -l) )); then
            echo "❌ $cpu_num: Current frequency is $cur_freq (${percent}% of max $max_freq) - Possible throttling"
        else
            echo "✅ $cpu_num: Current frequency is $cur_freq (${percent}% of max $max_freq)"
        fi
    done
else
    echo "CPU frequency information not available"
fi

echo -e "\n=== Monitoring Complete ==="
echo "Run this script periodically to check if optimizations are working correctly." 