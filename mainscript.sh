#!/bin/bash

# Server Performance Optimization Script
# This script optimizes CPU, RAM, network settings and SSH for high performance

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Progress and UI Functions
show_progress() {
    local duration=${1:-1}
    local width=50
    local progress=0
    
    echo -ne "${YELLOW}Progress: [${NC}"
    while [ $progress -lt $width ]; do
        echo -ne "${GREEN}#${NC}"
        progress=$((progress + 1))
        sleep $(echo "scale=3; $duration/$width" | bc)
    done
    echo -e "${YELLOW}] Done!${NC}"
}

# Function to show animated dots
show_dots() {
    local message=$1
    local duration=${2:-3}
    local interval=0.5
    local dots=""
    local elapsed=0
    
    echo -ne "$message"
    while (( $(echo "$elapsed < $duration" | bc -l) )); do
        echo -ne "."
        sleep $interval
        elapsed=$(echo "$elapsed + $interval" | bc)
    done
    echo -e " ${GREEN}Done!${NC}"
}

# Animation functions
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

loading_bar() {
    local duration=$1
    local width=50
    local interval=$(echo "scale=3; $duration/$width" | bc)
    
    echo -ne "${YELLOW}["
    for ((i=0; i<$width; i++)); do
        echo -ne "${GREEN}#"
        sleep $interval
    done
    echo -e "${YELLOW}] ${GREEN}Done!${NC}"
}

show_welcome_banner() {
    clear
    echo -e "${CYAN}"
    echo "   _____ _   _          _____  ______    ____  _____ _______ _____ ______"
    echo "  / ____| \ | |   /\   |  __ \|  ____|  / __ \|  __ \__   __|_   _|___  /"
    echo " | (___ |  \| |  /  \  | |__) | |__    | |  | | |__) | | |    | |    / / "
    echo "  \\___ \| . \` | / /\\ \ |  _  /|  __|   | |  | |  ___/  | |    | |   / /  "
    echo "  ____) | |\\  |/ ____ \\| | \\ \| |____  | |__| | |      | |   _| |_ / /__ "
    echo " |_____/|_| \_/_/    \_\_|  \_\______|  \____/|_|      |_|  |_____/_____|"
    echo -e "${NC}"
    echo -e "${YELLOW}Advanced Linux Server Optimization Tool${NC}"
    echo -e "${PURPLE}Version 2.0 - By SNAREFPS${NC}"
    echo -e "${RED}Note: XanMod kernel installation is not included in full optimization${NC}"
    echo -e "${BLUE}----------------------------------------${NC}"
    echo
    # --- System Summary Section ---
    # Gather system info
    local hostname=$(hostname)
    local os=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
    local cpu=$(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^ *//')
    local cpu_cores=$(nproc)
    local ram=$(free -h | awk '/^Mem:/ {print $2}')
    local disk_total=$(df -h / | awk 'END{print $2}')
    local disk_free=$(df -h / | awk 'END{print $4}')
    local ipv4=$(hostname -I | awk '{print $1}')
    local ipv6=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | head -n1)
    local uptime=$(uptime -p)
    # Print summary box (columnar)
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    printf "${GREEN}║${NC}  ${CYAN}Host:${NC} %-22s ${CYAN}CPU:${NC} %-30s ${GREEN}║\n" "$hostname" "$cpu"
    printf "${GREEN}║${NC}  ${CYAN}OS:${NC} %-24s ${CYAN}Cores:${NC} %-3s ${CYAN}RAM:${NC} %-10s ${GREEN}║\n" "$os" "$cpu_cores" "$ram"
    printf "${GREEN}║${NC}  ${CYAN}Disk:${NC} %-10s free / %-10s total ${CYAN}Uptime:${NC} %-18s ${GREEN}║\n" "$disk_free" "$disk_total" "$uptime"
    printf "${GREEN}║${NC}  ${CYAN}IPv4:${NC} ${RED}%-39s${NC} ${CYAN}IPv6:${NC} %-30s${GREEN}║\n" "$ipv4" "${ipv6:-N/A}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    # Show loading animation
    echo -ne "${CYAN}Initializing SNARE OPTIZ"
    for i in {1..5}; do
        echo -ne "."
        sleep 0.2
    done
    echo -e "${NC}"
    loading_bar 2
    echo
}

# Function to display section header
section_header() {
    local title=$1
    local cols=$(tput cols)
    local title_len=${#title}
    local padding=$(( (cols - title_len - 4) / 2 ))
    
    echo -e "\n${BLUE}$(printf '=%.0s' $(seq 1 $cols))${NC}"
    echo -e "${BLUE}=$(printf ' %.0s' $(seq 1 $padding))${CYAN} $title ${BLUE}$(printf ' %.0s' $(seq 1 $padding))=${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $cols))${NC}\n"
}

# Function to display success message
success_msg() {
    echo -e "${GREEN}✓ $1${NC}"
    echo -ne "${CYAN}Processing"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.1
    done
    echo -e "${NC}"
}

# Function to display error message
error_msg() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to display info message
info_msg() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Must run as root
if [ "$(id -u)" -ne 0 ]; then
    error_msg "This script must be run as root"
    exit 1
fi

# Function to optimize DNS settings
optimize_dns() {
    local description="This will optimize your DNS settings by:
- Adding fast and reliable DNS servers (Cloudflare and Google)
- Enabling DNSSEC for security
- Configuring DNS over TLS
- Optimizing DNS caching

This is recommended for better DNS resolution speed and security."

    if show_description_and_confirm "DNS OPTIMIZATION" "$description"; then
        section_header "DNS OPTIMIZATION"
        info_msg "Optimizing DNS settings..."

        # Backup resolv.conf
        cp /etc/resolv.conf /etc/resolv.conf.bak
        success_msg "Backed up original resolv.conf"

        # Add popular DNS servers
        cat > /etc/resolv.conf << EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
        success_msg "Added Cloudflare and Google DNS servers"

        # Optimize systemd-resolved if available
        if systemctl is-active systemd-resolved >/dev/null 2>&1; then
            cat > /etc/systemd/resolved.conf << EOF
[Resolve]
DNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
FallbackDNS=9.9.9.9 149.112.112.112
DNSSEC=yes
DNSOverTLS=yes
Cache=yes
DNSStubListener=yes
EOF
            systemctl restart systemd-resolved
            success_msg "Optimized systemd-resolved configuration"
        fi

        show_progress 1
        success_msg "DNS optimization completed"
    fi
}

# Function to install XanMod kernel
install_xanmod() {
    local description="This will install the XanMod kernel which provides:
- Better system responsiveness
- Lower latency
- Improved CPU scheduling
- Enhanced network stack
- Optimized for modern processors

This is recommended for getting maximum performance from your hardware."

    if show_description_and_confirm "XANMOD KERNEL INSTALLATION" "$description"; then
        section_header "XANMOD KERNEL INSTALLATION"
        info_msg "Installing XanMod kernel..."

        # Add XanMod repository
        curl -fsSL https://dl.xanmod.org/gpg.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg
        echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

        # Update and install XanMod kernel
        apt update
        apt install -y linux-xanmod-x64v3
        success_msg "XanMod kernel installed"

        show_progress 1
        success_msg "XanMod kernel installation completed"
        info_msg "Please reboot your system to use the new kernel"
    fi
}

# Function to configure BBR and congestion control
configure_bbr() {
    local description="This will configure TCP congestion control with options:
- BBR: Google's standard congestion control algorithm
- BBR2: Newer version with improved performance
- BBRplus: Enhanced version with additional features
- BBRv2: Latest version with better congestion handling

This is recommended for optimizing network throughput."

    if show_description_and_confirm "BBR CONFIGURATION" "$description"; then
        section_header "BBR CONFIGURATION"
        info_msg "Configuring TCP congestion control..."

        echo -e "${CYAN}Available congestion control algorithms:${NC}"
        echo "1. BBR (Google's TCP congestion control)"
        echo "2. BBR2 (Newer version of BBR)"
        echo "3. BBRplus (BBR with additional features)"
        echo "4. BBRv2 (BBR version 2)"
        echo "5. Return to main menu"
        echo
        read -p "Select congestion control algorithm [1-5]: " bbr_choice

        case $bbr_choice in
            1)
                cat > /etc/sysctl.d/99-bbr.conf << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
                success_msg "BBR configured"
                ;;
            2)
                cat > /etc/sysctl.d/99-bbr.conf << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr2
EOF
                success_msg "BBR2 configured"
                ;;
            3)
                cat > /etc/sysctl.d/99-bbr.conf << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbrplus
EOF
                success_msg "BBRplus configured"
                ;;
            4)
                cat > /etc/sysctl.d/99-bbr.conf << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbrv2
EOF
                success_msg "BBRv2 configured"
                ;;
            5)
                return
                ;;
            *)
                error_msg "Invalid option"
                return
                ;;
        esac

        sysctl --system
        show_progress 2
        success_msg "TCP congestion control configuration completed"
        show_dots "Processing" 1
    fi
}

# Function to set timezone
set_timezone() {
    local description="This will set your system timezone.
- You can select from common timezones (e.g., Asia/Tehran, Europe/London, America/New_York)
- Or enter a custom timezone.

This is recommended to ensure correct date and time display."

    if show_description_and_confirm "TIMEZONE CONFIGURATION" "$description"; then
        section_header "TIMEZONE CONFIGURATION"
        info_msg "Setting system timezone..."

        # Get current timezone
        current_tz=$(timedatectl | grep "Time zone" | awk '{print $3}')
        info_msg "Current timezone: $current_tz"

        # List common timezones
        echo -e "\n${CYAN}Common timezones:${NC}"
        echo "1. Asia/Tehran (Iran)"
        echo "2. Europe/London (UK)"
        echo "3. America/New_York (US East)"
        echo "4. Asia/Dubai (UAE)"
        echo "5. Europe/Berlin (Germany)"
        echo "6. Europe/Paris (France)"
        echo "7. Europe/Amsterdam (Netherlands)"
        echo "8. Europe/Helsinki (Finland)"
        echo "9. Custom timezone"
        echo "10. Return to main menu"
        echo
        read -p "Select timezone [1-10]: " tz_choice

        case $tz_choice in
            1) timedatectl set-timezone Asia/Tehran ;;
            2) timedatectl set-timezone Europe/London ;;
            3) timedatectl set-timezone America/New_York ;;
            4) timedatectl set-timezone Asia/Dubai ;;
            5) timedatectl set-timezone Europe/Berlin ;;
            6) timedatectl set-timezone Europe/Paris ;;
            7) timedatectl set-timezone Europe/Amsterdam ;;
            8) timedatectl set-timezone Europe/Helsinki ;;
            9)
                # Interactive timezone selection
                echo -e "\n${CYAN}Select timezone region:${NC}"
                regions=($(timedatectl list-timezones | cut -d'/' -f1 | sort | uniq))
                for i in "${!regions[@]}"; do
                    echo "$((i+1)). ${regions[i]}"
                done
                echo
                read -p "Enter region number: " region_num
                
                if [[ $region_num =~ ^[0-9]+$ ]] && [ $region_num -ge 1 ] && [ $region_num -le ${#regions[@]} ]; then
                    selected_region=${regions[$((region_num-1))]}
                    echo -e "\n${CYAN}Select city in ${selected_region}:${NC}"
                    cities=($(timedatectl list-timezones | grep "^${selected_region}/" | cut -d'/' -f2- | sort))
                    
                    # Display cities with paging if there are many
                    if [ ${#cities[@]} -gt 20 ]; then
                        echo -e "${YELLOW}There are ${#cities[@]} cities. Showing in pages.${NC}"
                        page=0
                        page_size=20
                        total_pages=$(( (${#cities[@]} + page_size - 1) / page_size ))
                        
                        while true; do
                            start_idx=$((page * page_size))
                            end_idx=$(( start_idx + page_size - 1 ))
                            if [ $end_idx -ge ${#cities[@]} ]; then
                                end_idx=$((${#cities[@]} - 1))
                            fi
                            
                            echo -e "\n${CYAN}Page $((page+1))/$total_pages:${NC}"
                            for i in $(seq $start_idx $end_idx); do
                                echo "$((i+1)). ${cities[i]}"
                            done
                            
                            echo -e "\n${YELLOW}[n]${NC} Next page, ${YELLOW}[p]${NC} Previous page, ${YELLOW}[s]${NC} Select city, ${YELLOW}[c]${NC} Cancel"
                            read -p "Action: " page_action
                            
                            case $page_action in
                                n|N) 
                                    if [ $page -lt $((total_pages-1)) ]; then
                                        page=$((page+1))
                                    fi
                                    ;;
                                p|P)
                                    if [ $page -gt 0 ]; then
                                        page=$((page-1))
                                    fi
                                    ;;
                                s|S)
                                    read -p "Enter city number: " city_num
                                    if [[ $city_num =~ ^[0-9]+$ ]] && [ $city_num -ge 1 ] && [ $city_num -le ${#cities[@]} ]; then
                                        selected_city=${cities[$((city_num-1))]}
                                        custom_tz="${selected_region}/${selected_city}"
                                        timedatectl set-timezone "$custom_tz"
                                        success_msg "Timezone set to $custom_tz"
                                    else
                                        error_msg "Invalid city number"
                                    fi
                                    break
                                    ;;
                                c|C)
                                    return
                                    ;;
                            esac
                        done
                    else
                        # If few cities, show them all at once
                        for i in "${!cities[@]}"; do
                            echo "$((i+1)). ${cities[i]}"
                        done
                        echo
                        read -p "Enter city number: " city_num
                        
                        if [[ $city_num =~ ^[0-9]+$ ]] && [ $city_num -ge 1 ] && [ $city_num -le ${#cities[@]} ]; then
                            selected_city=${cities[$((city_num-1))]}
                            custom_tz="${selected_region}/${selected_city}"
                            timedatectl set-timezone "$custom_tz"
                            success_msg "Timezone set to $custom_tz"
                        else
                            error_msg "Invalid city number"
                            return
                        fi
                    fi
                else
                    error_msg "Invalid region number"
                    return
                fi
                ;;
            10) return ;;
            *) 
                error_msg "Invalid option"
                return
                ;;
        esac

        new_tz=$(timedatectl | grep "Time zone" | awk '{print $3}')
        success_msg "Timezone updated to: $new_tz"
        show_progress 1
    fi
}

# Function to show option description and get confirmation
show_description_and_confirm() {
    local title=$1
    local description=$2
    
    section_header "$title"
    echo -e "${YELLOW}Description:${NC}"
    echo -e "$description"
    echo
    read -p "Do you want to proceed with this optimization? (y/n): " confirm
    [[ "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]]
}

# Update show_main_menu with animated border
show_main_menu() {
    local width=60
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "${CYAN}║${NC}                     ${GREEN}SNARE OPTIZ MENU${NC}                      ${CYAN}║${NC}"
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo
    echo -e "${GREEN}1.${NC} Run full optimization (recommended) ${YELLOW}[XanMod not included]${NC}"
    echo -e "${GREEN}2.${NC} Optimize CPU settings only"
    echo -e "${GREEN}3.${NC} Optimize memory settings only"
    echo -e "${GREEN}4.${NC} Optimize network settings only"
    echo -e "${GREEN}5.${NC} Optimize SSH settings only"
    echo -e "${GREEN}6.${NC} Setup anti-throttling measures only"
    echo -e "${GREEN}7.${NC} Optimize DNS settings"
    echo -e "${GREEN}8.${NC} Install XanMod kernel ${CYAN}[Separate Installation]${NC}"
    echo -e "${GREEN}9.${NC} Configure BBR options"
    echo -e "${GREEN}10.${NC} Set system timezone"
    echo -e "${GREEN}11.${NC} Show current system status"
    echo -e "${GREEN}12.${NC} Advanced Options ${PURPLE}[NEW!]${NC}"
    echo -e "${GREEN}13.${NC} Network Bandwidth Limiter ${YELLOW}[NEW!]${NC}"
    echo -e "${GREEN}14.${NC} Exit"
    echo
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -n "Enter your choice [1-14]: "
}

# Function to optimize CPU
optimize_cpu() {
    local description="This will optimize your CPU settings by:
- Setting CPU governor to performance mode
- Optimizing kernel scheduler parameters
- Disabling CPU throttling
- Improving process scheduling

This is recommended for servers that need maximum CPU performance."

    if show_description_and_confirm "CPU OPTIMIZATION" "$description"; then
        section_header "CPU OPTIMIZATION"
        info_msg "Optimizing CPU settings..."
    
        # Set CPU governor to performance
        if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                echo "performance" > $cpu
            done
            success_msg "CPU governor set to performance mode"
        else
            info_msg "CPU frequency scaling not available"
        fi

        # Disable CPU throttling
        echo "1" > /proc/sys/kernel/sched_autogroup_enabled
        echo "0" > /proc/sys/kernel/sched_child_runs_first
        success_msg "CPU throttling disabled"

        # Optimize CPU scheduler for throughput
        cat > /etc/sysctl.d/99-cpu-scheduler.conf << EOF
# CPU scheduler optimizations
kernel.sched_migration_cost_ns = 5000000
kernel.sched_autogroup_enabled = 0
kernel.sched_latency_ns = 10000000
kernel.sched_min_granularity_ns = 3000000
kernel.sched_wakeup_granularity_ns = 4000000
EOF
        success_msg "CPU scheduler optimized for throughput"
        
        show_progress 1
        success_msg "CPU optimization completed"
    fi
}

# Function to optimize memory
optimize_memory() {
    section_header "MEMORY OPTIMIZATION"
    info_msg "Optimizing memory settings..."

    # Check if swap exists
    if [[ $(swapon -s | wc -l) -le 1 ]]; then
        info_msg "No swap found. Creating 2GB swap file..."
        # Create swap file
        dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        # Add to fstab if not already there
        if ! grep -q "/swapfile" /etc/fstab; then
            echo "/swapfile none swap sw 0 0" >> /etc/fstab
        fi
        success_msg "Swap file created and activated"
    else
        info_msg "Swap already exists. Checking size..."
        current_swap_kb=$(free | grep Swap | awk '{print $2}')
        current_swap_gb=$(echo "scale=2; $current_swap_kb/1024/1024" | bc)
        if (( $(echo "$current_swap_gb < 2" | bc -l) )); then
            info_msg "Current swap is less than 2GB. Adjusting..."
            swapoff -a
            rm -f /swapfile
            dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile
            success_msg "Swap resized to 2GB"
        else
            success_msg "Swap size is adequate"
        fi
    fi

    # Optimize swap usage
    sysctl -w vm.swappiness=10
    sysctl -w vm.vfs_cache_pressure=50
    sysctl -w vm.dirty_ratio=10
    sysctl -w vm.dirty_background_ratio=5

    # Add these settings to sysctl.conf if not already there
    local sysctl_conf="/etc/sysctl.conf"
    {
        echo "# Memory optimization settings"
        echo "vm.swappiness=10"
        echo "vm.vfs_cache_pressure=50"
        echo "vm.dirty_ratio=10"
        echo "vm.dirty_background_ratio=5"
    } >> "$sysctl_conf"

    # Clear page cache
    sync; echo 3 > /proc/sys/vm/drop_caches
    
    success_msg "Memory settings optimized"
    
    # Show current memory status
    echo -e "\n${CYAN}Current Memory Status:${NC}"
    free -h
}

# Function to optimize network
optimize_network() {
    local description="This will optimize your network settings by:
- Increasing network buffer sizes
- Optimizing TCP parameters
- Improving network throughput
- Reducing latency

This is recommended for servers that handle high network traffic."

    if show_description_and_confirm "NETWORK OPTIMIZATION" "$description"; then
        section_header "NETWORK OPTIMIZATION"
        info_msg "Optimizing network settings..."
    
        # Enable BBR congestion control algorithm
        cat > /etc/sysctl.d/99-network-bbr.conf << EOF
# Enable BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
        success_msg "BBR congestion control enabled"

        # Increase network performance
        cat > /etc/sysctl.d/99-network-performance.conf << EOF
# Network performance settings
net.core.somaxconn = 65536
net.core.netdev_max_backlog = 65536
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_local_port_range = 1024 65535
EOF
        success_msg "Network buffers and TCP parameters optimized"
        
        show_progress 1
        success_msg "Network optimization completed"
    fi
}

# Function to optimize SSH
optimize_ssh() {
    local description="This will optimize your SSH settings by:
- Configuring keep-alive settings
- Enabling compression
- Increasing max sessions
- Optimizing SSH tunnel performance

This is recommended for servers that use SSH tunneling extensively."

    if show_description_and_confirm "SSH OPTIMIZATION" "$description"; then
        section_header "SSH OPTIMIZATION"
        info_msg "Optimizing SSH settings..."
    
        # Backup original SSH config
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        success_msg "Original SSH config backed up to /etc/ssh/sshd_config.bak"

        # Update SSH configuration
        cat >> /etc/ssh/sshd_config << EOF

# SSH Tunnel Optimization
ClientAliveInterval 60
ClientAliveCountMax 3
TCPKeepAlive yes
Compression yes
MaxSessions 100
UseDNS no
EOF
        success_msg "SSH optimized for better tunnel performance"
        
        # Restart SSH service
        systemctl restart sshd
        success_msg "SSH service restarted with new settings"
        
        show_progress 1
        success_msg "SSH optimization completed"
    fi
}

# Function to setup process priority management
setup_process_priority() {
    section_header "PROCESS PRIORITY MANAGEMENT"
    info_msg "Setting up process priority management..."
    
    # Install cpulimit if not present
    if ! command -v cpulimit &> /dev/null; then
        info_msg "Installing cpulimit..."
        apt-get update && apt-get install -y cpulimit || yum install -y cpulimit
        success_msg "cpulimit installed"
    else
        success_msg "cpulimit already installed"
    fi

    # Create a script to manage SSH process priority
    cat > /usr/local/bin/ssh-priority.sh << EOF
#!/bin/bash
# Set SSH processes to higher priority
for pid in \$(pgrep -f "sshd:"); do
    renice -n -5 \$pid
    ionice -c 2 -n 0 -p \$pid
done
EOF

    chmod +x /usr/local/bin/ssh-priority.sh
    success_msg "SSH priority script created"

    # Add to crontab to run every 5 minutes
    (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/ssh-priority.sh") | crontab -
    success_msg "SSH priority management added to crontab"
    
    show_progress 1
    success_msg "Process priority management setup completed"
}

# Function to setup anti-throttling measures
setup_anti_throttling() {
    local description="This will set up anti-throttling measures by:
- Monitoring CPU usage
- Automatically managing process priorities
- Preventing CPU throttling by the datacenter
- Distributing load across processes

This is recommended if you experience CPU throttling issues."

    if show_description_and_confirm "ANTI-THROTTLING SETUP" "$description"; then
        section_header "ANTI-THROTTLING MEASURES"
        info_msg "Setting up anti-throttling measures..."
    
        # Create a script to detect and handle CPU throttling
        cat > /usr/local/bin/anti-throttle.sh << EOF
#!/bin/bash

# Function to check CPU usage
check_cpu() {
    CPU_USAGE=\$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - \$1}')
    echo "\$CPU_USAGE"
}

# Function to distribute load
distribute_load() {
    # Find high CPU processes
    HIGH_CPU_PROCESSES=\$(ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 10)
    
    # Limit CPU usage for processes using more than 80% CPU
    echo "\$HIGH_CPU_PROCESSES" | while read line; do
        PID=\$(echo \$line | awk '{print \$1}')
        CPU_PERCENT=\$(echo \$line | awk '{print \$4}')
        CMD=\$(echo \$line | awk '{print \$3}')
        
        # Skip system processes
        if [[ "\$CMD" == *"sshd"* ]] || [[ "\$CMD" == *"system"* ]]; then
            continue
        fi
        
        if (( \$(echo "\$CPU_PERCENT > 80" | bc -l) )); then
            cpulimit -p \$PID -l 70 &
        fi
    done
}

# Main loop
while true; do
    CPU=\$(check_cpu)
    if (( \$(echo "\$CPU > 85" | bc -l) )); then
        echo "High CPU detected: \$CPU% - Distributing load"
        distribute_load
    fi
    sleep 60
done
EOF

        chmod +x /usr/local/bin/anti-throttle.sh
        success_msg "Anti-throttle script created"

        # Create systemd service for anti-throttle
        cat > /etc/systemd/system/anti-throttle.service << EOF
[Unit]
Description=Anti CPU Throttling Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/anti-throttle.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF
        success_msg "Anti-throttle service created"

        # Enable and start anti-throttle service
        systemctl enable anti-throttle.service
        systemctl start anti-throttle.service
        success_msg "Anti-throttle service enabled and started"
        
        show_progress 1
        success_msg "Anti-throttling measures setup completed"
    fi
}

# Enhanced system status display
show_system_status() {
    section_header "SYSTEM STATUS"
    
    # System Information
    echo -e "${CYAN}System Information:${NC}"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Uptime: $(uptime -p)"
    
    # CPU Information
    echo -e "\n${CYAN}CPU Settings:${NC}"
    echo "CPU Model: $(lscpu | grep "Model name" | cut -d':' -f2- | sed 's/^[ \t]*//')"
    if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "$(basename $(dirname $(dirname $cpu))): $(cat $cpu)"
        done
    fi
    
    # Memory Settings
    echo -e "\n${CYAN}Memory Settings:${NC}"
    echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
    echo "VFS Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
    echo "Transparent Hugepages: $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
    free -h | grep -v + > /tmp/meminfo
    echo "Total Memory: $(awk '/Mem:/ {print $2}' /tmp/meminfo)"
    echo "Used Memory: $(awk '/Mem:/ {print $3}' /tmp/meminfo)"
    echo "Free Memory: $(awk '/Mem:/ {print $4}' /tmp/meminfo)"
    
    # Network Settings
    echo -e "\n${CYAN}Network Settings:${NC}"
    echo "TCP Congestion Control: $(cat /proc/sys/net/ipv4/tcp_congestion_control)"
    echo "Default Qdisc: $(cat /proc/sys/net/core/default_qdisc)"
    echo "BBR Status: $(lsmod | grep -q bbr && echo "Enabled" || echo "Disabled")"
    
    # DNS Settings
    echo -e "\n${CYAN}DNS Settings:${NC}"
    echo "Current DNS Servers:"
    cat /etc/resolv.conf | grep nameserver
    if systemctl is-active systemd-resolved >/dev/null 2>&1; then
        echo "systemd-resolved status: Active"
        resolvectl status | grep "DNS Servers" || true
    fi
    
    # SSH Settings
    echo -e "\n${CYAN}SSH Settings:${NC}"
    grep -E "ClientAliveInterval|Compression|TCPKeepAlive" /etc/ssh/sshd_config | grep -v "#" || echo "No custom SSH settings found"
    
    # Anti-throttle Status
    echo -e "\n${CYAN}Anti-Throttle Service:${NC}"
    systemctl status anti-throttle.service --no-pager | head -n 3
    
    # XanMod Kernel Check
    echo -e "\n${CYAN}XanMod Kernel Status:${NC}"
    if uname -r | grep -q xanmod; then
        echo "XanMod kernel is installed and active"
        echo "Version: $(uname -r)"
    else
        echo "Standard kernel is in use"
        echo "Version: $(uname -r)"
    fi
    
    # Timezone Information
    echo -e "\n${CYAN}Timezone Settings:${NC}"
    timedatectl | grep "Time zone"
    
    # Performance Metrics
    echo -e "\n${CYAN}Current Performance Metrics:${NC}"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "CPU Usage:"
    top -bn1 | head -n 3 | tail -n 2
    
    echo
    read -p "Press Enter to return to main menu..."
}

# Update run_full_optimization with better visual feedback
run_full_optimization() {
    section_header "FULL SYSTEM OPTIMIZATION"
    info_msg "Starting comprehensive system optimization..."
    echo -e "${YELLOW}Note: XanMod kernel installation is not included and must be installed separately${NC}"
    echo
    
    local steps=9
    local current=1
    
    echo -e "${CYAN}Optimization Progress:${NC}"
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Optimizing CPU..."
    optimize_cpu
    ((current++))
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Optimizing Memory..."
    optimize_memory
    ((current++))
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Optimizing Network..."
    optimize_network
    ((current++))
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Optimizing SSH..."
    optimize_ssh
    ((current++))
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Setting up Process Priority..."
    setup_process_priority
    ((current++))
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Configuring Anti-throttling..."
    setup_anti_throttling
    ((current++))
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Optimizing DNS..."
    optimize_dns
    ((current++))
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Configuring BBR..."
    configure_bbr
    ((current++))
    
    echo -e "\n${GREEN}[$current/$steps]${NC} Setting Timezone..."
    set_timezone
    
    section_header "APPLYING CHANGES"
    info_msg "Applying all system changes..."
    sysctl --system
    
    section_header "OPTIMIZATION COMPLETE"
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Server Optimization Completed!      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo
    info_msg "Some changes require a reboot to take full effect."
    info_msg "It's recommended to reboot the server when possible."
    echo
    echo -e "${YELLOW}Don't forget: XanMod kernel can be installed separately using option 8 from the main menu${NC}"
    echo
    
    read -p "Would you like to reboot now? (y/n): " reboot_choice
    if [[ "$reboot_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Rebooting system in 5 seconds..."
        for i in {5..1}; do
            echo -ne "\rRebooting in $i seconds..."
            sleep 1
        done
        echo -e "\rRebooting now!                 "
        reboot
    fi
}

# Advanced Reporting Functions
generate_report() {
    local report_file="/var/log/snare_optiz/optimization_$(date +%Y%m%d_%H%M%S).log"
    mkdir -p /var/log/snare_optiz

    {
        echo "=== SNARE OPTIZ Optimization Report ==="
        echo "Date: $(date)"
        echo "System Information:"
        echo "==================="
        uname -a
        echo
        echo "CPU Information:"
        echo "==============="
        lscpu | grep -E "Model name|CPU MHz|CPU(s)|Thread|Core"
        echo
        echo "Memory Information:"
        echo "=================="
        free -h
        echo
        echo "Storage Information:"
        echo "==================="
        df -h
        echo
        echo "Network Information:"
        echo "==================="
        ip addr show
        echo
        echo "Current Settings:"
        echo "================"
        sysctl -a 2>/dev/null
        echo
        echo "Applied Optimizations:"
        echo "===================="
        cat /var/log/snare_optiz/applied_changes.log 2>/dev/null || echo "No previous optimizations found"
    } > "$report_file"

    success_msg "Report generated at $report_file"
}

# Server Profile Functions
apply_server_profile() {
    local profile=$1
    case $profile in
        "game")
            # Game Server Optimizations
            sysctl -w net.ipv4.tcp_fastopen=3
            sysctl -w net.ipv4.tcp_fin_timeout=15
            sysctl -w net.ipv4.tcp_keepalive_time=300
            success_msg "Applied Game Server profile"
            ;;
        "web")
            # Web Server Optimizations
            sysctl -w net.ipv4.tcp_max_syn_backlog=65536
            sysctl -w net.ipv4.tcp_syncookies=1
            sysctl -w net.ipv4.tcp_max_tw_buckets=1440000
            success_msg "Applied Web Server profile"
            ;;
        "database")
            # Database Server Optimizations
            sysctl -w vm.dirty_ratio=60
            sysctl -w vm.dirty_background_ratio=2
            sysctl -w vm.dirty_expire_centisecs=1000
            success_msg "Applied Database Server profile"
            ;;
        "streaming")
            # Streaming Server Optimizations
            sysctl -w net.core.wmem_max=16777216
            sysctl -w net.core.rmem_max=16777216
            sysctl -w net.ipv4.tcp_window_scaling=1
            success_msg "Applied Streaming Server profile"
            ;;
    esac
}

# Live Monitoring Functions
show_live_stats() {
    clear
    echo -e "${CYAN}Press Ctrl+C to exit monitoring${NC}"
    while true; do
        clear
        echo -e "${YELLOW}=== SNARE OPTIZ Live Monitor ===${NC}"
        echo -e "${CYAN}Time: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
        echo
        
        # CPU Usage Graph
        echo -e "${GREEN}CPU Usage:${NC}"
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
        draw_graph $cpu_usage
        
        # Memory Usage Graph
        echo -e "\n${GREEN}Memory Usage:${NC}"
        memory_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
        draw_graph $memory_usage
        
        # Load Average
        echo -e "\n${GREEN}Load Average:${NC}"
        uptime | awk -F'load average:' '{print $2}'
        
        # Network Stats
        echo -e "\n${GREEN}Network I/O:${NC}"
        netstat -i | head -n2
        
        # Disk I/O
        echo -e "\n${GREEN}Disk I/O:${NC}"
        iostat -x 1 1 | tail -n3
        
        sleep 2
    done
}

draw_graph() {
    local percentage=$1
    local width=50
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '.'
    printf "] %d%%\n" "$percentage"
}

# Advanced UI Functions
show_advanced_menu() {
    local width=70
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "${CYAN}║${NC}                    ${GREEN}SNARE OPTIZ ADVANCED MENU${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo
    echo -e "${GREEN}A.${NC} Server Profiles ${CYAN}[Specialized Optimizations]${NC}"
    echo -e "${GREEN}B.${NC} Live System Monitor ${CYAN}[Real-time Performance]${NC}"
    echo -e "${GREEN}C.${NC} Generate System Report ${CYAN}[Detailed Analysis]${NC}"
    echo -e "${GREEN}D.${NC} System Diagnostics ${CYAN}[Problem Detection]${NC}"
    echo -e "${GREEN}E.${NC} Return to Main Menu"
    echo
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -n "Enter your choice [A-E]: "
}

# System Diagnostics Functions
check_cpu_governor() {
    local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    if [[ "$governor" != "performance" ]]; then
        echo -e "${YELLOW}⚠ CPU Governor is set to '$governor'. Recommended: 'performance'${NC}"
    else
        echo -e "${GREEN}✓ CPU Governor is optimally configured${NC}"
    fi
}

check_cpu_scaling() {
    local scaling_max=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)
    local cpuinfo_max=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null)
    
    if [[ "$scaling_max" != "$cpuinfo_max" ]]; then
        echo -e "${YELLOW}⚠ CPU frequency scaling might be limiting performance${NC}"
    else
        echo -e "${GREEN}✓ CPU frequency scaling is optimal${NC}"
    fi
}

check_memory_usage() {
    local memory_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    if [[ $memory_usage -gt 90 ]]; then
        echo -e "${RED}⚠ High memory usage detected: ${memory_usage}%${NC}"
    elif [[ $memory_usage -gt 80 ]]; then
        echo -e "${YELLOW}⚠ Memory usage is elevated: ${memory_usage}%${NC}"
    else
        echo -e "${GREEN}✓ Memory usage is normal: ${memory_usage}%${NC}"
    fi
}

check_swap_usage() {
    local swap_total=$(free | grep Swap | awk '{print $2}')
    if [[ $swap_total -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No swap space configured${NC}"
        return
    fi
    local swap_used=$(free | grep Swap | awk '{print int($3/$2 * 100)}')
    if [[ $swap_used -gt 50 ]]; then
        echo -e "${YELLOW}⚠ High swap usage detected: ${swap_used}%${NC}"
    else
        echo -e "${GREEN}✓ Swap usage is normal: ${swap_used}%${NC}"
    fi
}

check_network_config() {
    local backlog=$(sysctl -n net.ipv4.tcp_max_syn_backlog)
    if [[ $backlog -lt 2048 ]]; then
        echo -e "${YELLOW}⚠ TCP backlog size might be too small: $backlog${NC}"
    else
        echo -e "${GREEN}✓ TCP backlog size is adequate${NC}"
    fi
}

check_connection_limits() {
    local current_max=$(sysctl -n net.core.somaxconn)
    if [[ $current_max -lt 1024 ]]; then
        echo -e "${YELLOW}⚠ Connection limits might be too low: $current_max${NC}"
    else
        echo -e "${GREEN}✓ Connection limits are adequate${NC}"
    fi
}

check_disk_io() {
    if ! command -v iostat &> /dev/null; then
        echo -e "${YELLOW}⚠ iostat command not found. Installing sysstat package...${NC}"
        if command -v apt &> /dev/null; then
            apt-get update && apt-get install -y sysstat
        elif command -v yum &> /dev/null; then
            yum install -y sysstat
        else
            echo -e "${RED}⚠ Package manager not found. Please install sysstat manually.${NC}"
            return
        fi
    fi
    
    local iostat_output=$(iostat -x 1 1 2>/dev/null | grep -v '^$' | tail -n1)
    if [[ $? -eq 0 ]]; then
        local util=$(echo "$iostat_output" | awk '{print $NF}')
        if [[ $(echo "$util > 80" | bc 2>/dev/null) -eq 1 ]]; then
            echo -e "${RED}⚠ High disk utilization detected: ${util}%${NC}"
        else
            echo -e "${GREEN}✓ Disk I/O utilization is normal${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Could not check disk I/O utilization${NC}"
    fi
}

check_filesystem_status() {
    local fs_status=$(df -h / | tail -n1)
    local usage_percent=$(echo $fs_status | awk '{print $5}' | sed 's/%//')
    if [[ $usage_percent -gt 90 ]]; then
        echo -e "${RED}⚠ Root filesystem usage is critical: ${usage_percent}%${NC}"
    elif [[ $usage_percent -gt 80 ]]; then
        echo -e "${YELLOW}⚠ Root filesystem usage is high: ${usage_percent}%${NC}"
    else
        echo -e "${GREEN}✓ Filesystem usage is normal: ${usage_percent}%${NC}"
    fi
}

check_critical_services() {
    local services=("sshd" "systemd" "cron")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service 2>/dev/null; then
            echo -e "${GREEN}✓ $service is running${NC}"
        else
            echo -e "${RED}⚠ $service is not running${NC}"
        fi
    done
}

run_diagnostics() {
    section_header "SYSTEM DIAGNOSTICS"
    echo -e "${YELLOW}Running comprehensive system checks...${NC}"
    
    # CPU Checks
    echo -e "\n${GREEN}[1/5] Checking CPU Configuration...${NC}"
    check_cpu_governor
    check_cpu_scaling
    
    # Memory Checks
    echo -e "\n${GREEN}[2/5] Analyzing Memory Usage...${NC}"
    check_memory_usage
    check_swap_usage
    
    # Network Checks
    echo -e "\n${GREEN}[3/5] Verifying Network Settings...${NC}"
    check_network_config
    check_connection_limits
    
    # Storage Checks
    echo -e "\n${GREEN}[4/5] Examining Storage Performance...${NC}"
    check_disk_io
    check_filesystem_status
    
    # Service Checks
    echo -e "\n${GREEN}[5/5] Validating System Services...${NC}"
    check_critical_services
    
    
    
    # Auto-run diagnostics when entering this section
    echo -e "\n${CYAN}=== AUTO-DIAGNOSTICS RESULTS ===${NC}"
    echo -e "${YELLOW}Running automatic system health check...${NC}"
    
    # Quick health check
    local health_score=0
    local total_checks=0
    
    # CPU Health Check
    if [[ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null) == "performance" ]]; then
        echo -e "${GREEN}✓ CPU Governor: Optimal${NC}"
        ((health_score++))
    else
        echo -e "${RED}✗ CPU Governor: Needs optimization${NC}"
    fi
    ((total_checks++))
    
    # Memory Health Check
    local memory_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    if [[ $memory_usage -lt 80 ]]; then
        echo -e "${GREEN}✓ Memory Usage: ${memory_usage}% (Good)${NC}"
        ((health_score++))
    else
        echo -e "${RED}✗ Memory Usage: ${memory_usage}% (High)${NC}"
    fi
    ((total_checks++))
    
    # Network Health Check
    local backlog=$(sysctl -n net.ipv4.tcp_max_syn_backlog)
    if [[ $backlog -ge 2048 ]]; then
        echo -e "${GREEN}✓ Network Backlog: ${backlog} (Good)${NC}"
        ((health_score++))
    else
        echo -e "${RED}✗ Network Backlog: ${backlog} (Low)${NC}"
    fi
    ((total_checks++))
    
    # Disk Health Check
    local disk_usage=$(df -h / | tail -n1 | awk '{print $5}' | sed 's/%//')
    if [[ $disk_usage -lt 80 ]]; then
        echo -e "${GREEN}✓ Disk Usage: ${disk_usage}% (Good)${NC}"
        ((health_score++))
    else
        echo -e "${RED}✗ Disk Usage: ${disk_usage}% (High)${NC}"
    fi
    ((total_checks++))
    
    # Service Health Check
    local service_issues=0
    local critical_services=("sshd" "systemd" "cron")
    for service in "${critical_services[@]}"; do
        if ! systemctl is-active --quiet $service 2>/dev/null; then
            ((service_issues++))
        fi
    done
    
    if [[ $service_issues -eq 0 ]]; then
        echo -e "${GREEN}✓ Critical Services: All running${NC}"
        ((health_score++))
    else
        echo -e "${RED}✗ Critical Services: ${service_issues} issues detected${NC}"
    fi
    ((total_checks++))
    
    # Calculate and display health score
    local health_percentage=$((health_score * 100 / total_checks))
    echo -e "\n${CYAN}=== SYSTEM HEALTH SCORE ===${NC}"
    
    if [[ $health_percentage -ge 80 ]]; then
        echo -e "${GREEN}🏆 System Health: ${health_percentage}% (EXCELLENT)${NC}"
    elif [[ $health_percentage -ge 60 ]]; then
        echo -e "${YELLOW}⚠️  System Health: ${health_percentage}% (GOOD)${NC}"
    elif [[ $health_percentage -ge 40 ]]; then
        echo -e "${YELLOW}⚠️  System Health: ${health_percentage}% (FAIR)${NC}"
    else
        echo -e "${RED}🚨 System Health: ${health_percentage}% (POOR)${NC}"
    fi
    
    echo -e "${CYAN}Health Score: ${health_score}/${total_checks} checks passed${NC}"

    generate_optimization_recommendations
    
    # Auto-recommendations based on health score
    if [[ $health_percentage -lt 80 ]]; then
        echo -e "\n${YELLOW}💡 Auto-Recommendations:${NC}"
        if [[ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null) != "performance" ]]; then
            echo -e "   • Run CPU optimization (Option 2)"
        fi
        if [[ $memory_usage -gt 80 ]]; then
            echo -e "   • Run Memory optimization (Option 3)"
        fi
        if [[ $backlog -lt 2048 ]]; then
            echo -e "   • Run Network optimization (Option 4)"
        fi
        if [[ $disk_usage -gt 80 ]]; then
            echo -e "   • Check disk space and clean unnecessary files"
        fi
        echo -e "   • Consider running full optimization (Option 1)"
    else
        echo -e "\n${GREEN}🎉 Your system is in excellent condition!${NC}"
    fi
}

generate_optimization_recommendations() {
    section_header "OPTIMIZATION RECOMMENDATIONS"
    echo -e "${CYAN}Based on system analysis, here are recommended optimizations:${NC}\n"
    
    local recommendations=()
    local need_optimization=false
    
    # CPU Recommendations
    if [[ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null) != "performance" ]]; then
        recommendations+=("Set CPU governor to 'performance' mode for better processing speed")
        need_optimization=true
    fi
    
    # Memory Recommendations
    local memory_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    if [[ $memory_usage -gt 80 ]]; then
        recommendations+=("Optimize memory usage or consider adding more RAM")
        need_optimization=true
    fi
    
    # Network Recommendations
    local backlog=$(sysctl -n net.ipv4.tcp_max_syn_backlog)
    if [[ $backlog -lt 2048 ]]; then
        recommendations+=("Increase TCP backlog size for better network performance")
        need_optimization=true
    fi
    
    # Display and Apply Recommendations
    if [[ ${#recommendations[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓ System is well optimized! No immediate actions needed.${NC}"
    else
        for i in "${!recommendations[@]}"; do
            echo -e "${YELLOW}${i+1}. ${recommendations[$i]}${NC}"
        done
        
        echo
        echo -e "${CYAN}Would you like to apply these optimizations automatically? [Y/n]${NC}"
        read -t 10 apply_choice
        
        if [[ -z "$apply_choice" ]] || [[ "$apply_choice" =~ ^[Yy]$ ]]; then
            echo -e "\n${GREEN}Applying optimizations...${NC}"
            
            # Apply CPU optimizations
            if [[ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null) != "performance" ]]; then
                for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                    echo "performance" > "$cpu" 2>/dev/null
                done
                echo -e "${GREEN}✓ Set CPU governor to performance mode${NC}"
            fi
            
            # Apply memory optimizations
            if [[ $memory_usage -gt 80 ]]; then
                sysctl -w vm.swappiness=10
                sysctl -w vm.vfs_cache_pressure=50
                echo -e "${GREEN}✓ Applied memory optimizations${NC}"
            fi
            
            # Apply network optimizations
            if [[ $backlog -lt 2048 ]]; then
                sysctl -w net.ipv4.tcp_max_syn_backlog=4096
                sysctl -w net.core.somaxconn=4096
                echo -e "${GREEN}✓ Increased network connection limits${NC}"
            fi
            
            echo -e "\n${GREEN}✓ All recommended optimizations have been applied!${NC}"
        else
            echo -e "\n${YELLOW}Optimizations were not applied. You can apply them manually from the main menu.${NC}"
        fi
    fi
}

# Update main menu to include new advanced options
show_main_menu() {
    local width=60
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "${CYAN}║${NC}                     ${GREEN}SNARE OPTIZ MENU${NC}                      ${CYAN}║${NC}"
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo
    echo -e "${GREEN}1.${NC} Run full optimization (recommended) ${YELLOW}[XanMod not included]${NC}"
    echo -e "${GREEN}2.${NC} Optimize CPU settings only"
    echo -e "${GREEN}3.${NC} Optimize memory settings only"
    echo -e "${GREEN}4.${NC} Optimize network settings only"
    echo -e "${GREEN}5.${NC} Optimize SSH settings only"
    echo -e "${GREEN}6.${NC} Setup anti-throttling measures only"
    echo -e "${GREEN}7.${NC} Optimize DNS settings"
    echo -e "${GREEN}8.${NC} Install XanMod kernel ${CYAN}[Separate Installation]${NC}"
    echo -e "${GREEN}9.${NC} Configure BBR options"
    echo -e "${GREEN}10.${NC} Set system timezone"
    echo -e "${GREEN}11.${NC} Show current system status"
    echo -e "${GREEN}12.${NC} Advanced Options ${PURPLE}[NEW!]${NC}"
    echo -e "${GREEN}13.${NC} Network Bandwidth Limiter ${YELLOW}[NEW!]${NC}"
    echo -e "${GREEN}14.${NC} Exit"
    echo
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -n "Enter your choice [1-14]: "
}

# Add new function for bandwidth limiting
network_bandwidth_limiter() {
    section_header "NETWORK BANDWIDTH LIMITER"
    info_msg "This feature allows you to safely limit your server's network bandwidth using wondershaper."
    
    # Check and install wondershaper if needed
    if ! command -v wondershaper &>/dev/null; then
        info_msg "Installing wondershaper..."
        if command -v apt-get &>/dev/null; then
            apt-get update && apt-get install -y wondershaper
        elif command -v yum &>/dev/null; then
            yum install -y epel-release && yum install -y wondershaper
        elif command -v dnf &>/dev/null; then
            dnf install -y wondershaper
        else
            error_msg "No supported package manager found. Please install wondershaper manually."
            return
        fi
    fi
    
    # List interfaces
    echo -e "\n${CYAN}Available network interfaces:${NC}"
    interfaces=( $(ls /sys/class/net | grep -v lo) )
    select iface in "${interfaces[@]}" "Cancel"; do
        if [[ "$iface" == "Cancel" ]]; then
            return
        elif [[ -n "$iface" ]]; then
            break
        else
            error_msg "Invalid selection. Try again."
        fi
    done
    
    # Preset bandwidths (in Mbit/s)
    echo -e "\n${CYAN}Select bandwidth limit:${NC}"
    echo "1. 50 Mbit/s"
    echo "2. 100 Mbit/s"
    echo "3. 1 Gbit/s"
    echo "4. 2 Gbit/s"
    echo "5. 5 Gbit/s"
    echo "6. 10 Gbit/s"
    echo "7. Custom value (Mbit/s)"
    echo "8. Remove limit (reset)"
    echo "9. Cancel"
    read -p "Enter choice [1-9]: " bw_choice
    case $bw_choice in
        1) rate=50 ;;
        2) rate=100 ;;
        3) rate=1000 ;;
        4) rate=2000 ;;
        5) rate=5000 ;;
        6) rate=10000 ;;
        7)
            read -p "Enter custom bandwidth in Mbit/s (e.g. 75): " custom_rate
            if [[ "$custom_rate" =~ ^[0-9]+$ ]] && [ "$custom_rate" -gt 0 ]; then
                rate=$custom_rate
            else
                error_msg "Invalid value."
                return
            fi
            ;;
        8)
            wondershaper clear $iface
            success_msg "Bandwidth limit removed from $iface."
            return
            ;;
        9) return ;;
        *) error_msg "Invalid option."; return ;;
    esac
    
    # Confirm and apply
    echo -e "\n${YELLOW}You are about to limit $iface to $rate Mbit/s (both up & down).${NC}"
    read -p "Are you sure? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        info_msg "Operation cancelled."
        return
    fi
    wondershaper $iface $rate $rate
    if [ $? -eq 0 ]; then
        success_msg "Bandwidth limit of $rate Mbit/s applied to $iface."
    else
        error_msg "Failed to apply bandwidth limit."
    fi
}

# Update main program loop
while true; do
    show_welcome_banner
    show_main_menu
    read choice
    
    case $choice in
        1) run_full_optimization ;;
        2) optimize_cpu ;;
        3) optimize_memory ;;
        4) optimize_network ;;
        5) optimize_ssh ;;
        6) setup_anti_throttling ;;
        7) optimize_dns ;;
        8) install_xanmod ;;
        9) configure_bbr ;;
        10) set_timezone ;;
        11) show_system_status ;;
        12)
            while true; do
                clear
                show_advanced_menu
                read advanced_choice
                case $advanced_choice in
                    [Aa])
                        echo -e "\n${CYAN}Select Server Profile:${NC}"
                        echo "1. Game Server"
                        echo "2. Web Server"
                        echo "3. Database Server"
                        echo "4. Streaming Server"
                        echo -n "Enter choice [1-4]: "
                        read profile_choice
                        case $profile_choice in
                            1) apply_server_profile "game" ;;
                            2) apply_server_profile "web" ;;
                            3) apply_server_profile "database" ;;
                            4) apply_server_profile "streaming" ;;
                            *) error_msg "Invalid profile choice" ;;
                        esac
                        ;;
                    [Bb]) show_live_stats ;;
                    [Cc]) generate_report ;;
                    [Dd]) run_diagnostics ;;
                    [Ee]) break ;;
                    *) error_msg "Invalid advanced option" ;;
                esac
                if [[ $advanced_choice != [Bb] ]]; then
                    echo
                    read -p "Press Enter to return to advanced menu..."
                fi
            done
            ;;
        13) network_bandwidth_limiter ;;
        14)
            echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║  Thank you for using SNARE OPTIZ! ║${NC}"
            echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
            exit 0
            ;;
        *)
            error_msg "Invalid option. Please try again."
            sleep 2
            ;;
    esac
    
    if [ "$choice" != "11" ] && [ "$choice" != "12" ]; then
        echo
        read -p "Press Enter to return to main menu..."
    fi
done 