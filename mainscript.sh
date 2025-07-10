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

# Function to show option description and get confirmation
show_description_and_confirm() {
    local title=$1
    local description=$2
    
    local width=70
    echo -e "${CYAN}╭$(printf '─%.0s' $(seq 1 $width))╮${NC}"
    echo -e "${CYAN}│${NC}                      ${PURPLE}⚡ $title ⚡${NC}                      ${CYAN}│${NC}"
    echo -e "${CYAN}├$(printf '─%.0s' $(seq 1 $width))┤${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}Description:${NC}                                                    ${CYAN}│${NC}"
    
    # Word wrap the description
    local desc_lines=$(echo "$description" | fold -s -w 65)
    while IFS= read -r line; do
        printf "${CYAN}│${NC} %-68s ${CYAN}│${NC}\n" "$line"
    done <<< "$desc_lines"
    
    echo -e "${CYAN}├$(printf '─%.0s' $(seq 1 $width))┤${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}Proceed with this optimization? [y/n]:${NC}                           ${CYAN}│${NC}"
    echo -e "${CYAN}╰$(printf '─%.0s' $(seq 1 $width))╯${NC}"
    echo
    read -p "$(echo -e ${GREEN}">>${NC} ")" confirm
    [[ "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]]
}

# Function to display section header
section_header() {
    local title=$1
    local width=70
    echo
    echo -e "${CYAN}╭$(printf '─%.0s' $(seq 1 $width))╮${NC}"
    echo -e "${CYAN}│${NC}$(printf '%*s' $(( (width + ${#title}) / 2)) "${PURPLE}⚡ $title ⚡${NC}")$(printf '%*s' $(( (width - ${#title}) / 2)) "")${CYAN}│${NC}"
    echo -e "${CYAN}╰$(printf '─%.0s' $(seq 1 $width))╯${NC}"
    echo
}

# Progress and UI Functions
show_progress() {
    local duration=${1:-1}
    local width=50
    local progress=0
    
    echo -ne "${YELLOW}Progress: ${NC}"
    echo -ne "${CYAN}[${NC}"
    while [ $progress -lt $width ]; do
        echo -ne "${GREEN}⚡${NC}"
        progress=$((progress + 1))
        sleep $(echo "scale=3; $duration/$width" | bc)
    done
    echo -e "${CYAN}]${NC} ${GREEN}✓${NC}"
}

# Function to show animated dots
show_dots() {
    local message=$1
    local duration=${2:-3}
    local interval=0.5
    local dots=""
    local elapsed=0
    
    echo -ne "${YELLOW}$message${NC}"
    while (( $(echo "$elapsed < $duration" | bc -l) )); do
        echo -ne "${GREEN}⚡${NC}"
        sleep $interval
        elapsed=$(echo "$elapsed + $interval" | bc)
    done
    echo -e " ${GREEN}✓${NC}"
}

# Function to show spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " %c  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to show animated loading bar
loading_bar() {
    local duration=$1
    local width=50
    local interval=$(echo "scale=3; $duration/$width" | bc)
    
    echo -ne "${CYAN}[${NC}"
    for ((i=0; i<$width; i++)); do
        echo -ne "${YELLOW}⚡${NC}"
        sleep $interval
    done
    echo -e "${CYAN}]${NC} ${GREEN}✓${NC}"
}

show_welcome_banner() {
    clear
    echo -e "${CYAN}"
    echo "    ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡"
    echo "    ⚡                                                          ⚡"
    echo -e "    ⚡        ${PURPLE}███████╗███╗   ██╗ █████╗ ██████╗ ███████╗${CYAN}        ⚡"
    echo -e "    ⚡        ${PURPLE}██╔════╝████╗  ██║██╔══██╗██╔══██╗██╔════╝${CYAN}        ⚡"
    echo -e "    ⚡        ${PURPLE}███████╗██╔██╗ ██║███████║██████╔╝█████╗${CYAN}          ⚡"
    echo -e "    ⚡        ${PURPLE}╚════██║██║╚██╗██║██╔══██║██╔══██╗██╔══╝${CYAN}          ⚡"
    echo -e "    ⚡        ${PURPLE}███████║██║ ╚████║██║  ██║██║  ██║███████╗${CYAN}        ⚡"
    echo -e "    ⚡        ${PURPLE}╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝${CYAN}        ⚡"
    echo "    ⚡                                                          ⚡"
    echo -e "    ⚡        ${GREEN}██████╗ ██████╗ ████████╗██╗███████╗${CYAN}              ⚡"
    echo -e "    ⚡        ${GREEN}██╔══██╗██╔══██╗╚══██╔══╝██║╚══███╔╝${CYAN}              ⚡"
    echo -e "    ⚡        ${GREEN}██║  ██║██████╔╝   ██║   ██║  ███╔╝${CYAN}               ⚡"
    echo -e "    ⚡        ${GREEN}██║  ██║██╔═══╝    ██║   ██║ ███╔╝${CYAN}                ⚡"
    echo -e "    ⚡        ${GREEN}██████╔╝██║        ██║   ██║███████╗${CYAN}              ⚡"
    echo -e "    ⚡        ${GREEN}╚═════╝ ╚═╝        ╚═╝   ╚═╝╚══════╝${CYAN}              ⚡"
    echo "    ⚡                                                          ⚡"
    echo "    ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡"
    echo -e "${NC}"
    echo -e "           ${YELLOW}🚀 Advanced Linux Server Optimization Tool${NC}"
    echo -e "           ${PURPLE}Version 2.0 - Powered by SNAREFPS${NC}"
    echo -e "           ${RED}Note: XanMod kernel requires separate installation${NC}"
    echo
    echo -e "${BLUE}╭───────────────────── System Summary ─────────────────────╮${NC}"
    
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

    # Print summary with icons and better formatting
    echo -e "${CYAN}│${NC}  🖥️  ${GREEN}Host:${NC} $hostname"
    echo -e "${CYAN}│${NC}  🐧 ${GREEN}OS:${NC} $os"
    echo -e "${CYAN}│${NC}  💻 ${GREEN}CPU:${NC} $cpu ($cpu_cores cores)"
    echo -e "${CYAN}│${NC}  🎮 ${GREEN}RAM:${NC} $ram"
    echo -e "${CYAN}│${NC}  💾 ${GREEN}Disk:${NC} $disk_free free of $disk_total"
    echo -e "${CYAN}│${NC}  🌐 ${GREEN}IPv4:${NC} ${RED}$ipv4${NC}"
    echo -e "${CYAN}│${NC}  🔗 ${GREEN}IPv6:${NC} ${ipv6:-N/A}"
    echo -e "${CYAN}│${NC}  ⏰ ${GREEN}Uptime:${NC} $uptime"
    echo -e "${BLUE}╰──────────────────────────────────────────────────────────╯${NC}"
    echo

    # Show loading animation
    echo -ne "${CYAN}⚡ Initializing SNARE OPTIZ  "
    for i in {1..5}; do
        echo -ne "${YELLOW} ⚡ ${NC}"
        sleep 0.2
    done
    echo
    
    # Show progress bar with lightning effect
    echo -ne "${CYAN}["
    for i in {1..50}; do
        echo -ne "${YELLOW}⚡${NC}"
        sleep 0.02
    done
    echo -e "${CYAN}]${NC}"
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
        
        echo -e "${CYAN}╭─ DNS Configuration Steps ───────────────────────────────────────╮${NC}"
        
        # Backup resolv.conf
        echo -e "${CYAN}│${NC} 📋 Backing up current DNS configuration..."
        cp /etc/resolv.conf /etc/resolv.conf.bak
        success_msg "Backed up original resolv.conf"

        # Add popular DNS servers
        echo -e "${CYAN}│${NC} 🔄 Configuring new DNS servers..."
        cat > /etc/resolv.conf << EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
        success_msg "Added Cloudflare and Google DNS servers"

        # Optimize systemd-resolved if available
        if is_systemd_available && systemctl is-active systemd-resolved >/dev/null 2>&1; then
            echo -e "${CYAN}│${NC} ⚙️ Optimizing systemd-resolved..."
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

        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
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
        
        echo -e "${CYAN}╭─ XanMod Installation Steps ────────────────────────────────────╮${NC}"
        
        # Add XanMod repository
        echo -e "${CYAN}│${NC} 🔑 Adding XanMod repository key..."
        curl -fsSL https://dl.xanmod.org/gpg.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg
        
        echo -e "${CYAN}│${NC} 📦 Configuring repository..."
        echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

        # Update and install XanMod kernel
        echo -e "${CYAN}│${NC} 🔄 Updating package lists..."
        apt update
        
        echo -e "${CYAN}│${NC} 💿 Installing XanMod kernel..."
        apt install -y linux-xanmod-x64v3
        success_msg "XanMod kernel installed"

        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
        show_progress 1
        success_msg "XanMod kernel installation completed"
        info_msg "Please reboot your system to use the new kernel"
    fi
}

# Function to configure BBR
configure_bbr() {
    local description="This will configure TCP congestion control with options:
- BBR: Google's standard congestion control algorithm
- BBR2: Newer version with improved performance
- BBRplus: Enhanced version with additional features
- BBRv2: Latest version with better congestion handling

This is recommended for optimizing network throughput."

    if show_description_and_confirm "BBR CONFIGURATION" "$description"; then
        section_header "BBR CONFIGURATION"
        
        echo -e "${CYAN}╭─ Available BBR Options ──────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│${NC}                                                                    ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[1]${NC} 🚀 BBR (Google's TCP congestion control)                      ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[2]${NC} 🔥 BBR2 (Newer version of BBR)                               ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[3]${NC} ⚡ BBRplus (BBR with additional features)                     ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[4]${NC} 💫 BBRv2 (BBR version 2)                                     ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${RED}[5]${NC} 🚪 Return to main menu                                         ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}                                                                    ${CYAN}│${NC}"
        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
        echo
        echo -ne "${GREEN}Select congestion control algorithm${NC} ${YELLOW}[1-5]${NC}: "
        read bbr_choice

        case $bbr_choice in
            1)
                echo -e "${CYAN}╭─ Configuring BBR ───────────────────────────────────────────╮${NC}"
                cat > /etc/sysctl.d/99-bbr.conf << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
                success_msg "BBR configured"
                ;;
            2)
                echo -e "${CYAN}╭─ Configuring BBR2 ──────────────────────────────────────────╮${NC}"
                cat > /etc/sysctl.d/99-bbr.conf << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr2
EOF
                success_msg "BBR2 configured"
                ;;
            3)
                echo -e "${CYAN}╭─ Configuring BBRplus ───────────────────────────────────────╮${NC}"
                cat > /etc/sysctl.d/99-bbr.conf << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbrplus
EOF
                success_msg "BBRplus configured"
                ;;
            4)
                echo -e "${CYAN}╭─ Configuring BBRv2 ──────────────────────────────────────────╮${NC}"
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
        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
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
        
        # Get current timezone
        current_tz=$(timedatectl | grep "Time zone" | awk '{print $3}')
        
        echo -e "${CYAN}╭─ Timezone Configuration ────────────────────────────────────────╮${NC}"
        echo -e "${CYAN}│${NC} 🕒 Current timezone: $current_tz"
        echo -e "${CYAN}│${NC}                                                                    ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC} Common timezones:                                                  ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[1]${NC} 🌅 Asia/Tehran (Iran)                                        ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[2]${NC} 🌍 Europe/London (UK)                                       ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[3]${NC} 🌎 America/New_York (US East)                               ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[4]${NC} 🌅 Asia/Dubai (UAE)                                         ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[5]${NC} 🌍 Europe/Berlin (Germany)                                  ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[6]${NC} 🌍 Europe/Paris (France)                                    ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[7]${NC} 🌍 Europe/Amsterdam (Netherlands)                           ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[8]${NC} 🌍 Europe/Helsinki (Finland)                                ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${GREEN}[9]${NC} 🌐 Custom timezone                                          ${CYAN}│${NC}"
        echo -e "${CYAN}│${NC}  ${RED}[10]${NC} 🚪 Return to main menu                                       ${CYAN}│${NC}"
        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
        echo
        echo -ne "${GREEN}Select timezone${NC} ${YELLOW}[1-10]${NC}: "
        read tz_choice

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
                echo -e "${CYAN}╭─ Custom Timezone Selection ─────────────────────────────────╮${NC}"
                # Interactive timezone selection
                echo -e "${CYAN}│${NC} Select timezone region:"
                regions=($(timedatectl list-timezones | cut -d'/' -f1 | sort | uniq))
                for i in "${!regions[@]}"; do
                    printf "${CYAN}│${NC}  ${GREEN}[%d]${NC} %s\n" "$((i+1))" "${regions[i]}"
                done
                echo -e "${CYAN}│${NC}"
                echo -ne "${GREEN}Enter region number${NC}: "
                read region_num
                
                if [[ $region_num =~ ^[0-9]+$ ]] && [ $region_num -ge 1 ] && [ $region_num -le ${#regions[@]} ]; then
                    selected_region=${regions[$((region_num-1))]}
                    echo -e "${CYAN}│${NC} Select city in ${selected_region}:"
                    cities=($(timedatectl list-timezones | grep "^${selected_region}/" | cut -d'/' -f2- | sort))
                    
                    # Display cities with paging if there are many
                    if [ ${#cities[@]} -gt 20 ]; then
                        echo -e "${YELLOW}│ There are ${#cities[@]} cities. Showing in pages.${NC}"
                        page=0
                        page_size=20
                        total_pages=$(( (${#cities[@]} + page_size - 1) / page_size ))
                        
                        while true; do
                            start_idx=$((page * page_size))
                            end_idx=$(( start_idx + page_size - 1 ))
                            if [ $end_idx -ge ${#cities[@]} ]; then
                                end_idx=$((${#cities[@]} - 1))
                            fi
                            
                            echo -e "${CYAN}│${NC} Page $((page+1))/$total_pages:"
                            for i in $(seq $start_idx $end_idx); do
                                printf "${CYAN}│${NC}  ${GREEN}[%d]${NC} %s\n" "$((i+1))" "${cities[i]}"
                            done
                            
                            echo -e "${CYAN}│${NC}"
                            echo -e "${CYAN}│${NC} ${YELLOW}[n]${NC} Next page, ${YELLOW}[p]${NC} Previous page, ${YELLOW}[s]${NC} Select city, ${YELLOW}[c]${NC} Cancel"
                            echo -ne "${GREEN}Action${NC}: "
                            read page_action
                            
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
                                    echo -ne "${GREEN}Enter city number${NC}: "
                                    read city_num
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
                            printf "${CYAN}│${NC}  ${GREEN}[%d]${NC} %s\n" "$((i+1))" "${cities[i]}"
                        done
                        echo -e "${CYAN}│${NC}"
                        echo -ne "${GREEN}Enter city number${NC}: "
                        read city_num
                        
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
                echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
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
        
        echo -e "${CYAN}╭─ CPU Configuration Steps ──────────────────────────────────────╮${NC}"
        
        # Set CPU governor to performance
        echo -e "${CYAN}│${NC} ⚡ Configuring CPU governor..."
        if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                echo "performance" > $cpu
            done
            success_msg "CPU governor set to performance mode"
        else
            info_msg "CPU frequency scaling not available"
        fi

        # Disable CPU throttling
        echo -e "${CYAN}│${NC} 🔧 Optimizing CPU throttling settings..."
        echo "1" > /proc/sys/kernel/sched_autogroup_enabled
        echo "0" > /proc/sys/kernel/sched_child_runs_first
        success_msg "CPU throttling disabled"

        # Optimize CPU scheduler for throughput
        echo -e "${CYAN}│${NC} ⚙️ Configuring CPU scheduler..."
        cat > /etc/sysctl.d/99-cpu-scheduler.conf << EOF
# CPU scheduler optimizations
kernel.sched_migration_cost_ns = 5000000
kernel.sched_autogroup_enabled = 0
kernel.sched_latency_ns = 10000000
kernel.sched_min_granularity_ns = 3000000
kernel.sched_wakeup_granularity_ns = 4000000
EOF
        success_msg "CPU scheduler optimized for throughput"
        
        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
        show_progress 1
        success_msg "CPU optimization completed"
    fi
}

# Function to optimize memory
optimize_memory() {
    section_header "MEMORY OPTIMIZATION"
    
    echo -e "${CYAN}╭─ Memory Configuration Steps ───────────────────────────────────╮${NC}"
    
    # Check if swap exists
    echo -e "${CYAN}│${NC} 🔍 Checking swap configuration..."
    if [[ $(swapon -s | wc -l) -le 1 ]]; then
        echo -e "${CYAN}│${NC} 💾 No swap found. Creating 2GB swap file..."
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
        echo -e "${CYAN}│${NC} 📊 Checking existing swap size..."
        current_swap_kb=$(free | grep Swap | awk '{print $2}')
        current_swap_gb=$(echo "scale=2; $current_swap_kb/1024/1024" | bc)
        if (( $(echo "$current_swap_gb < 2" | bc -l) )); then
            echo -e "${CYAN}│${NC} ⚡ Adjusting swap size to 2GB..."
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

    echo -e "${CYAN}│${NC} ⚙️ Optimizing memory settings..."
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

    echo -e "${CYAN}│${NC} 🧹 Clearing page cache..."
    # Clear page cache
    sync; echo 3 > /proc/sys/vm/drop_caches
    
    success_msg "Memory settings optimized"
    
    # Show current memory status
    echo -e "${CYAN}│${NC} 📊 Current Memory Status:"
    echo -e "${CYAN}│${NC} $(free -h | sed 's/^/│ /')"
    
    echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
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
        
        echo -e "${CYAN}╭─ Network Configuration Steps ────────────────────────────────╮${NC}"
        
        # Enable BBR congestion control algorithm
        echo -e "${CYAN}│${NC} 🚀 Enabling BBR congestion control..."
        cat > /etc/sysctl.d/99-network-bbr.conf << EOF
# Enable BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
        success_msg "BBR congestion control enabled"

        # Increase network performance
        echo -e "${CYAN}│${NC} ⚡ Optimizing network performance..."
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
        
        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
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
        
        echo -e "${CYAN}╭─ SSH Configuration Steps ───────────────────────────────────╮${NC}"
        
        # Backup original SSH config
        echo -e "${CYAN}│${NC} 📋 Backing up SSH configuration..."
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        success_msg "Original SSH config backed up to /etc/ssh/sshd_config.bak"

        # Update SSH configuration
        echo -e "${CYAN}│${NC} ⚙️ Optimizing SSH settings..."
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
        echo -e "${CYAN}│${NC} 🔄 Restarting SSH service..."
        systemctl restart sshd
        success_msg "SSH service restarted with new settings"
        
        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
        show_progress 1
        success_msg "SSH optimization completed"
    fi
}

# Function to setup process priority management
setup_process_priority() {
    section_header "PROCESS PRIORITY MANAGEMENT"
    
    echo -e "${CYAN}╭─ Process Priority Configuration ─────────────────────────────╮${NC}"
    
    # Install cpulimit if not present
    echo -e "${CYAN}│${NC} 🔍 Checking cpulimit installation..."
    if ! command -v cpulimit &> /dev/null; then
        echo -e "${CYAN}│${NC} 📦 Installing cpulimit..."
        apt-get update && apt-get install -y cpulimit || yum install -y cpulimit
        success_msg "cpulimit installed"
    else
        success_msg "cpulimit already installed"
    fi

    # Create a script to manage SSH process priority
    echo -e "${CYAN}│${NC} 📝 Creating SSH priority management script..."
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
    echo -e "${CYAN}│${NC} ⏰ Setting up automatic priority management..."
    (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/ssh-priority.sh") | crontab -
    success_msg "SSH priority management added to crontab"
    
    echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
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
        
        echo -e "${CYAN}╭─ Anti-Throttling Configuration ──────────────────────────────╮${NC}"
        
        # Create a script to detect and handle CPU throttling
        echo -e "${CYAN}│${NC} 📝 Creating anti-throttle script..."
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
        echo -e "${CYAN}│${NC} ⚙️ Creating anti-throttle service..."
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
        echo -e "${CYAN}│${NC} 🚀 Starting anti-throttle service..."
        if is_systemd_available; then
            systemctl enable anti-throttle.service
            systemctl start anti-throttle.service
            success_msg "Anti-throttle service enabled and started"
        else
            nohup /usr/local/bin/anti-throttle.sh >/dev/null 2>&1 &
            success_msg "Anti-throttle script started in background"
        fi
        
        echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
        show_progress 1
        success_msg "Anti-throttling measures setup completed"
    fi
}

# Function to show system status
show_system_status() {
    section_header "SYSTEM STATUS"
    
    echo -e "${CYAN}╭─ System Information ─────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🖥️  System Details:"
    echo -e "${CYAN}│${NC} ├─ Hostname: $(hostname)"
    echo -e "${CYAN}│${NC} ├─ Kernel: $(uname -r)"
    echo -e "${CYAN}│${NC} ├─ OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${CYAN}│${NC} └─ Uptime: $(uptime -p)"
    
    echo -e "${CYAN}├─ CPU Settings ───────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 💻 CPU Information:"
    echo -e "${CYAN}│${NC} ├─ Model: $(lscpu | grep "Model name" | cut -d':' -f2- | sed 's/^[ \t]*//')"
    if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
        echo -e "${CYAN}│${NC} └─ Governors:"
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo -e "${CYAN}│${NC}    ├─ $(basename $(dirname $(dirname $cpu))): $(cat $cpu)"
        done
    fi
    
    echo -e "${CYAN}├─ Memory Settings ────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 🎮 Memory Configuration:"
    echo -e "${CYAN}│${NC} ├─ Swappiness: $(cat /proc/sys/vm/swappiness)"
    echo -e "${CYAN}│${NC} ├─ VFS Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
    echo -e "${CYAN}│${NC} └─ Transparent Hugepages: $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
    free -h | grep -v + > /tmp/meminfo
    echo -e "${CYAN}│${NC} 📊 Memory Usage:"
    echo -e "${CYAN}│${NC} ├─ Total: $(awk '/Mem:/ {print $2}' /tmp/meminfo)"
    echo -e "${CYAN}│${NC} ├─ Used: $(awk '/Mem:/ {print $3}' /tmp/meminfo)"
    echo -e "${CYAN}│${NC} └─ Free: $(awk '/Mem:/ {print $4}' /tmp/meminfo)"
    
    echo -e "${CYAN}├─ Network Settings ────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 🌐 Network Configuration:"
    echo -e "${CYAN}│${NC} ├─ TCP Congestion Control: $(cat /proc/sys/net/ipv4/tcp_congestion_control)"
    echo -e "${CYAN}│${NC} ├─ Default Qdisc: $(cat /proc/sys/net/core/default_qdisc)"
    echo -e "${CYAN}│${NC} └─ BBR Status: $(lsmod | grep -q bbr && echo "Enabled" || echo "Disabled")"
    
    echo -e "${CYAN}├─ DNS Settings ───────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 🔍 DNS Servers:"
    cat /etc/resolv.conf | grep nameserver | sed 's/^/│ /'
    if is_systemd_available && systemctl is-active systemd-resolved >/dev/null 2>&1; then
        echo -e "${CYAN}│${NC} └─ systemd-resolved: Active"
        resolvectl status | grep "DNS Servers" | sed 's/^/│   /' || true
    fi
    
    echo -e "${CYAN}├─ SSH Settings ───────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 🔒 SSH Configuration:"
    grep -E "ClientAliveInterval|Compression|TCPKeepAlive" /etc/ssh/sshd_config | grep -v "#" | sed 's/^/│ /' || echo "│ No custom SSH settings found"
    
    echo -e "${CYAN}├─ Anti-Throttle Status ─────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ⚡ Service Status:"
    if is_systemd_available; then
        systemctl status anti-throttle.service --no-pager | head -n 3 | sed 's/^/│ /'
    else
        if pgrep -f "anti-throttle.sh" >/dev/null 2>&1; then
            echo -e "${CYAN}│${NC} └─ Anti-throttle service is running"
        else
            echo -e "${CYAN}│${NC} └─ Anti-throttle service is not running"
        fi
    fi
    
    echo -e "${CYAN}├─ XanMod Kernel Status ─────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 🖥️  Kernel Information:"
    if uname -r | grep -q xanmod; then
        echo -e "${CYAN}│${NC} ├─ Status: XanMod kernel is installed and active"
        echo -e "${CYAN}│${NC} └─ Version: $(uname -r)"
    else
        echo -e "${CYAN}│${NC} ├─ Status: Standard kernel is in use"
        echo -e "${CYAN}│${NC} └─ Version: $(uname -r)"
    fi
    
    echo -e "${CYAN}├─ Timezone Settings ───────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 🕒 Time Configuration:"
    timedatectl | grep "Time zone" | sed 's/^/│ /' || date +"%Z %z" | sed 's/^/│ /'
    
    echo -e "${CYAN}├─ Performance Metrics ──────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} 📈 Current Status:"
    echo -e "${CYAN}│${NC} ├─ Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "${CYAN}│${NC} └─ CPU Usage:"
    top -bn1 | head -n 3 | tail -n 2 | sed 's/^/│   /'
    
    echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
    echo
    read -p "Press Enter to return to main menu..."
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
    echo -e "${GREEN}13.${NC} Exit"
    echo
    echo -e "${CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -n "Enter your choice [1-13]: "
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
                read -n 1 -r advanced_choice
                echo
                case ${advanced_choice^^} in
                    A)
                        echo -e "\n${CYAN}Select Server Profile:${NC}"
                        echo "1. 🎮 Game Server"
                        echo "2. 🌐 Web Server"
                        echo "3. 💾 Database Server"
                        echo "4. 📺 Streaming Server"
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
                    B) show_live_stats ;;
                    C) generate_report ;;
                    D) run_diagnostics ;;
                    F) limit_bandwidth ;;
                    X|Q) break ;;
                    *) error_msg "Invalid advanced option" ;;
                esac
                if [[ ${advanced_choice^^} != "B" ]]; then
                    echo
                    read -p "Press Enter to return to advanced menu..."
                fi
            done
            ;;
        13)
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