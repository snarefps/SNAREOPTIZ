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
ORANGE='\033[0;33m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Progress and UI Functions
show_progress() {
    local duration=${1:-1}
    local width=50
    local progress=0
    local bar_char="▓"
    local empty_char="░"
    
    echo -ne "\n${CYAN}╭───── Progress ─────╮${NC}\n"
    echo -ne "${CYAN}│${NC} "
    while [ $progress -lt $width ]; do
        echo -ne "${GREEN}${bar_char}${NC}"
        progress=$((progress + 1))
        sleep $(echo "scale=3; $duration/$width" | bc)
    done
    echo -ne " ${CYAN}│${NC}"
    echo -e "\n${CYAN}╰───────────────────╯${NC}"
    echo -e "${GREEN}✨ Completed Successfully! ✨${NC}\n"
}

# Function to show animated dots
show_dots() {
    local message=$1
    local duration=${2:-3}
    local interval=0.5
    local dots=""
    local elapsed=0
    local spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    
    echo -ne "\n${CYAN}╭───── Processing ─────╮${NC}\n"
    echo -ne "${CYAN}│${NC} $message"
    while (( $(echo "$elapsed < $duration" | bc -l) )); do
        echo -ne "${YELLOW}${spinner[$i]}${NC}"
        sleep $interval
        echo -ne "\b"
        elapsed=$(echo "$elapsed + $interval" | bc)
        i=$(( (i + 1) % ${#spinner[@]} ))
    done
    echo -e " ${GREEN}✓${NC} ${CYAN}│${NC}"
    echo -e "${CYAN}╰────────────────────╯${NC}\n"
}

# Animation functions
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local temp
    echo -ne "${CYAN}╭───── Processing ─────╮${NC}\n"
    echo -ne "${CYAN}│${NC} "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        temp=${spinstr#?}
        echo -ne "${YELLOW}${spinstr}${NC}"
        local spinstr=$temp${spinstr%"$temp"}
        echo -ne "\b"
        sleep $delay
    done
    echo -e " ${GREEN}✓${NC} ${CYAN}│${NC}"
    echo -e "${CYAN}╰────────────────────╯${NC}\n"
}

loading_bar() {
    local duration=$1
    local width=50
    local interval=$(echo "scale=3; $duration/$width" | bc)
    local bar_char="▓"
    local empty_char="░"
    
    echo -ne "\n${CYAN}╭───── Loading ─────╮${NC}\n"
    echo -ne "${CYAN}│${NC} "
    for ((i=0; i<$width; i++)); do
        echo -ne "${GREEN}${bar_char}${NC}"
        sleep $interval
    done
    echo -ne " ${CYAN}│${NC}"
    echo -e "\n${CYAN}╰──────────────────╯${NC}\n"
    echo -e "${GREEN}✨ Loading Complete! ✨${NC}\n"
}

show_welcome_banner() {
    clear
    echo -e "${CYAN}"
    echo "    ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡"
    echo "    ╭──────────────────────────────────────────────────────╮"
    echo -e "    │        ${PURPLE}███████╗███╗   ██╗ █████╗ ██████╗ ███████╗${CYAN}        │"
    echo -e "    │        ${PURPLE}██╔════╝████╗  ██║██╔══██╗██╔══██╗██╔════╝${CYAN}        │"
    echo -e "    │        ${PURPLE}███████╗██╔██╗ ██║███████║██████╔╝█████╗${CYAN}          │"
    echo -e "    │        ${PURPLE}╚════██║██║╚██╗██║██╔══██║██╔══██╗██╔══╝${CYAN}          │"
    echo -e "    │        ${PURPLE}███████║██║ ╚████║██║  ██║██║  ██║███████╗${CYAN}        │"
    echo -e "    │        ${PURPLE}╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝${CYAN}        │"
    echo "    │                                                          │"
    echo -e "    │        ${GREEN}██████╗ ██████╗ ████████╗██╗███████╗${CYAN}              │"
    echo -e "    │        ${GREEN}██╔══██╗██╔══██╗╚══██╔══╝██║╚══███╔╝${CYAN}              │"
    echo -e "    │        ${GREEN}██║  ██║██████╔╝   ██║   ██║  ███╔╝${CYAN}               │"
    echo -e "    │        ${GREEN}██║  ██║██╔═══╝    ██║   ██║ ███╔╝${CYAN}                │"
    echo -e "    │        ${GREEN}██████╔╝██║        ██║   ██║███████╗${CYAN}              │"
    echo -e "    │        ${GREEN}╚═════╝ ╚═╝        ╚═╝   ╚═╝╚══════╝${CYAN}              │"
    echo "    │                                                          │"
    echo "    ╰──────────────────────────────────────────────────────╯"
    echo "    ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡ ⚡"
    echo -e "${NC}"
    echo -e "           ${YELLOW}🚀 Advanced Linux Server Optimization Tool${NC}"
    echo -e "           ${PURPLE}Version 2.0 - Powered by SNAREFPS${NC}"
    echo -e "           ${RED}Note: XanMod kernel requires separate installation${NC}"
    echo
    echo -e "${BLUE}╭───────────────────── System Summary ─────────────────────╮${NC}"
    
    # Gather system info with improved formatting
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

    # Print summary with modern formatting
    echo -e "${CYAN}│${NC}  🖥️  ${GREEN}Host:${NC}      ${WHITE}$hostname${NC}"
    echo -e "${CYAN}│${NC}  🐧 ${GREEN}OS:${NC}        ${WHITE}$os${NC}"
    echo -e "${CYAN}│${NC}  💻 ${GREEN}CPU:${NC}       ${WHITE}$cpu ($cpu_cores cores)${NC}"
    echo -e "${CYAN}│${NC}  🎮 ${GREEN}RAM:${NC}       ${WHITE}$ram${NC}"
    echo -e "${CYAN}│${NC}  💾 ${GREEN}Disk:${NC}      ${WHITE}$disk_free free of $disk_total${NC}"
    echo -e "${CYAN}│${NC}  🌐 ${GREEN}IPv4:${NC}      ${RED}$ipv4${NC}"
    echo -e "${CYAN}│${NC}  🔗 ${GREEN}IPv6:${NC}      ${WHITE}${ipv6:-N/A}${NC}"
    echo -e "${CYAN}│${NC}  ⏰ ${GREEN}Uptime:${NC}    ${WHITE}$uptime${NC}"
    echo -e "${BLUE}╰──────────────────────────────────────────────────────────╯${NC}"
    echo

    # Show loading animation with lightning effect
    echo -ne "${CYAN}⚡ Initializing SNARE OPTIZ  "
    for i in {1..5}; do
        echo -ne "${YELLOW}⚡${WHITE}✨${NC}"
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
    
    echo -e "\n${CYAN}╭$(printf '═%.0s' $(seq 1 $cols))╮${NC}"
    echo -e "${CYAN}│$(printf ' %.0s' $(seq 1 $padding))${PURPLE}⚡ $title ⚡${CYAN}$(printf ' %.0s' $(seq 1 $padding))│${NC}"
    echo -e "${CYAN}╰$(printf '═%.0s' $(seq 1 $cols))╯${NC}\n"
}

# Function to display success message
success_msg() {
    echo -e "\n${CYAN}╭─────── Success ───────╮${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}✓${NC} $1"
    echo -e "${CYAN}╰─────────────────────╯${NC}"
    
    # Show animated checkmark
    echo -ne "${GREEN}"
    for i in {1..3}; do
        echo -ne "✓"
        sleep 0.1
        echo -ne "\b"
    done
    echo -e "✓${NC}"
}

# Function to display error message
error_msg() {
    echo -e "\n${RED}╭─────── Error ───────╮${NC}"
    echo -e "${RED}│${NC} ${RED}✗${NC} $1"
    echo -e "${RED}╰────────────────────╯${NC}"
    
    # Show animated X
    echo -ne "${RED}"
    for i in {1..3}; do
        echo -ne "✗"
        sleep 0.1
        echo -ne "\b"
    done
    echo -e "✗${NC}"
}

# Function to display info message
info_msg() {
    echo -e "\n${BLUE}╭─────── Info ───────╮${NC}"
    echo -e "${BLUE}│${NC} ${YELLOW}ℹ${NC} $1"
    echo -e "${BLUE}╰────────────────────╯${NC}"
    
    # Show animated info symbol
    echo -ne "${YELLOW}"
    for i in {1..3}; do
        echo -ne "ℹ"
        sleep 0.1
        echo -ne "\b"
    done
    echo -e "ℹ${NC}"
}

# Function to display warning message
warning_msg() {
    echo -e "\n${ORANGE}╭─────── Warning ───────╮${NC}"
    echo -e "${ORANGE}│${NC} ${YELLOW}⚠${NC} $1"
    echo -e "${ORANGE}╰──────────────────────╯${NC}"
    
    # Show animated warning symbol
    echo -ne "${YELLOW}"
    for i in {1..3}; do
        echo -ne "⚠"
        sleep 0.1
        echo -ne "\b"
    done
    echo -e "⚠${NC}"
}

# Function to display human-readable bytes
human_readable_bytes() {
    local bytes=$1
    if ! [[ "$bytes" =~ ^[0-9]+$ ]] || [[ "$bytes" -ge 18446744073709551615 ]]; then
        echo "Unlimited"
        return
    fi

    if (( bytes < 1024 )); then
        echo "${bytes}B"
    elif (( bytes < 1048576 )); then
        printf "%.0fK\n" $((bytes/1024))
    elif (( bytes < 1073741824 )); then
        printf "%.0fM\n" $((bytes/1048576))
    else
        printf "%.1fG\n" $(echo "scale=1; $bytes/1073741824" | bc)
    fi
}

# Must run as root
if [ "$(id -u)" -ne 0 ]; then
    error_msg "This script must be run as root"
    exit 1
fi

# Check for bc and install if missing
if ! command -v bc &> /dev/null; then
    info_msg "'bc' is not installed. It is required for calculations. Attempting to install..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y bc
    elif command -v yum &> /dev/null; then
        yum install -y bc
    elif command -v dnf &> /dev/null; then
        dnf install -y bc
    else
        error_msg "Could not install 'bc'. Please install it manually and run the script again."
        exit 1
    fi
    
    if ! command -v bc &> /dev/null; then
        error_msg "Installation of 'bc' failed. Please install it manually."
        exit 1
    else
        success_msg "'bc' has been successfully installed."
    fi
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
        if is_systemd_available && systemctl is-active systemd-resolved >/dev/null 2>&1; then
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
- BBR2: Newer version of BBR
- BBRplus: BBR with additional features
- BBRv2: BBR version 2

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
    local width=70
    echo -e "${CYAN}╭$(printf '═%.0s' $(seq 1 $width))╮${NC}"
    echo -e "${CYAN}│${NC}                     ${PURPLE}⚡ SNARE OPTIZ MENU ⚡${NC}                      ${CYAN}│${NC}"
    echo -e "${CYAN}╞$(printf '═%.0s' $(seq 1 $width))╡${NC}"
    echo -e "${CYAN}│${NC}                                                                    ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[1]${NC} 🚀 Run full optimization ${YELLOW}[Recommended]${NC}                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[2]${NC} 💻 Optimize CPU settings                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[3]${NC} 🎮 Optimize memory settings                                      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[4]${NC} 🌐 Optimize network settings                                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[5]${NC} 🔒 Optimize SSH settings                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[6]${NC} ⚡ Setup anti-throttling measures                                ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[7]${NC} 🔍 Optimize DNS settings                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[8]${NC} 🖥️  Install XanMod kernel ${PURPLE}[Separate Installation]${NC}              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[9]${NC} 🔄 Configure BBR options                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[10]${NC} 🕒 Set system timezone                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[11]${NC} 📊 Show current system status                                  ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[12]${NC} ⚙️  Advanced Options ${PURPLE}[NEW!]${NC}                                   ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[13]${NC} 🚪 Exit                                                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}                                                                    ${CYAN}│${NC}"
    echo -e "${CYAN}╰$(printf '═%.0s' $(seq 1 $width))╯${NC}"
    echo
    echo -e "${GREEN}Enter your choice${NC} ${YELLOW}[1-13]${NC}: "
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
    echo -e "${CYAN}╭───────────── System Information ─────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🖥️  ${GREEN}Hostname:${NC} $(hostname)"
    echo -e "${CYAN}│${NC} 🐧 ${GREEN}Kernel:${NC} $(uname -r)"
    echo -e "${CYAN}│${NC} 📦 ${GREEN}OS:${NC} $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${CYAN}│${NC} ⏰ ${GREEN}Uptime:${NC} $(uptime -p)"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # CPU Information
    echo -e "\n${CYAN}╭───────────── CPU Settings ──────────────────╮${NC}"
    echo -e "${CYAN}│${NC} 💻 ${GREEN}CPU Model:${NC} $(lscpu | grep "Model name" | cut -d':' -f2- | sed 's/^[ \t]*//')"
    if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo -e "${CYAN}│${NC} ⚙️  ${GREEN}$(basename $(dirname $(dirname $cpu))):${NC} $(cat $cpu)"
        done
    fi
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # Memory Settings
    echo -e "\n${CYAN}╭───────────── Memory Settings ───────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🎮 ${GREEN}Swappiness:${NC} $(cat /proc/sys/vm/swappiness)"
    echo -e "${CYAN}│${NC} 📊 ${GREEN}VFS Cache Pressure:${NC} $(cat /proc/sys/vm/vfs_cache_pressure)"
    echo -e "${CYAN}│${NC} 📈 ${GREEN}Transparent Hugepages:${NC} $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
    free -h | grep -v + > /tmp/meminfo
    echo -e "${CYAN}│${NC} 💾 ${GREEN}Total Memory:${NC} $(awk '/Mem:/ {print $2}' /tmp/meminfo)"
    echo -e "${CYAN}│${NC} 📝 ${GREEN}Used Memory:${NC} $(awk '/Mem:/ {print $3}' /tmp/meminfo)"
    echo -e "${CYAN}│${NC} ✨ ${GREEN}Free Memory:${NC} $(awk '/Mem:/ {print $4}' /tmp/meminfo)"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # Network Settings
    echo -e "\n${CYAN}╭───────────── Network Settings ──────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🌐 ${GREEN}TCP Congestion Control:${NC} $(cat /proc/sys/net/ipv4/tcp_congestion_control)"
    echo -e "${CYAN}│${NC} 🔄 ${GREEN}Default Qdisc:${NC} $(cat /proc/sys/net/core/default_qdisc)"
    echo -e "${CYAN}│${NC} ⚡ ${GREEN}BBR Status:${NC} $(lsmod | grep -q bbr && echo "Enabled" || echo "Disabled")"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # DNS Settings
    echo -e "\n${CYAN}╭───────────── DNS Settings ─────────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🔍 ${GREEN}Current DNS Servers:${NC}"
    while read -r line; do
        if [[ $line == nameserver* ]]; then
            echo -e "${CYAN}│${NC}    ├─ ${WHITE}${line#nameserver }${NC}"
        fi
    done < /etc/resolv.conf
    if is_systemd_available && systemctl is-active systemd-resolved >/dev/null 2>&1; then
        echo -e "${CYAN}│${NC} ✓ ${GREEN}systemd-resolved status:${NC} Active"
        resolvectl status | grep "DNS Servers" | while read -r line; do
            echo -e "${CYAN}│${NC}    ├─ ${WHITE}${line}${NC}"
        done
    fi
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # SSH Settings
    echo -e "\n${CYAN}╭───────────── SSH Settings ─────────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🔒 ${GREEN}SSH Configuration:${NC}"
    grep -E "ClientAliveInterval|Compression|TCPKeepAlive" /etc/ssh/sshd_config | grep -v "#" | while read -r line; do
        echo -e "${CYAN}│${NC}    ├─ ${WHITE}$line${NC}"
    done || echo -e "${CYAN}│${NC}    └─ ${YELLOW}No custom SSH settings found${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # Anti-throttle Status
    echo -e "\n${CYAN}╭───────────── Anti-Throttle Service ─────────╮${NC}"
    if is_systemd_available; then
        systemctl status anti-throttle.service --no-pager | head -n 3 | while read -r line; do
            echo -e "${CYAN}│${NC} ⚡ ${line}"
        done
    else
        if pgrep -f "anti-throttle.sh" >/dev/null 2>&1; then
            echo -e "${CYAN}│${NC} ✅ ${GREEN}Anti-throttle service is running${NC}"
        else
            echo -e "${CYAN}│${NC} ❌ ${RED}Anti-throttle service is not running${NC}"
        fi
    fi
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # Resource Limits Status (cgroups)
    echo -e "\n${CYAN}╭───────────── Resource Limits Status ────────────────╮${NC}"
    if command -v systemctl &> /dev/null; then
        echo -e "${CYAN}│${NC} ✅ ${GREEN}systemd slice limits are active${NC}"
        
        local system_cpu_quota=$(systemctl show system.slice -p CPUQuota --value)
        local system_mem_max=$(systemctl show system.slice -p MemoryMax --value)
        
        local user_cpu_quota=$(systemctl show user.slice -p CPUQuota --value)
        local user_mem_max=$(systemctl show user.slice -p MemoryMax --value)

        echo -e "${CYAN}│${NC} 📊 ${GREEN}system.slice:${NC}"
        echo -e "${CYAN}│${NC}    ├─ CPU Quota: ${system_cpu_quota:-Not Set}"
        echo -e "${CYAN}│${NC}    └─ Memory Max: $(human_readable_bytes "${system_mem_max:-infinity}")"
        
        echo -e "${CYAN}│${NC} 📊 ${GREEN}user.slice:${NC}"
        echo -e "${CYAN}│${NC}    ├─ CPU Quota: ${user_cpu_quota:-Not Set}"
        echo -e "${CYAN}│${NC}    └─ Memory Max: $(human_readable_bytes "${user_mem_max:-infinity}")"
    else
        echo -e "${CYAN}│${NC} ℹ️ ${YELLOW}systemd not found, cannot check slice limits.${NC}"
    fi
    echo -e "${CYAN}╰─────────────────────────────────────────────────╯${NC}"

    # XanMod Kernel Check
    echo -e "\n${CYAN}╭───────────── XanMod Kernel Status ──────────╮${NC}"
    if uname -r | grep -q xanmod; then
        echo -e "${CYAN}│${NC} ✅ ${GREEN}XanMod kernel is installed and active${NC}"
        echo -e "${CYAN}│${NC} 📦 ${GREEN}Version:${NC} $(uname -r)"
    else
        echo -e "${CYAN}│${NC} ℹ️ ${YELLOW}Standard kernel is in use${NC}"
        echo -e "${CYAN}│${NC} 📦 ${GREEN}Version:${NC} $(uname -r)"
    fi
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # Timezone Information
    echo -e "\n${CYAN}╭───────────── Timezone Settings ──────────────╮${NC}"
    timedatectl | grep "Time zone" | while read -r line; do
        echo -e "${CYAN}│${NC} 🕒 ${GREEN}${line}${NC}"
    done || echo -e "${CYAN}│${NC} 🕒 ${GREEN}$(date +"%Z %z")${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # Performance Metrics
    echo -e "\n${CYAN}╭───────────── Performance Metrics ────────────╮${NC}"
    echo -e "${CYAN}│${NC} 📊 ${GREEN}Load Average:${NC} $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "${CYAN}│${NC} 💻 ${GREEN}CPU Usage:${NC}"
    top -bn1 | head -n 3 | tail -n 2 | while read -r line; do
        echo -e "${CYAN}│${NC}    ├─ ${WHITE}$line${NC}"
    done
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    echo
    echo -e "${GREEN}Press Enter to return to main menu...${NC}"
    read
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
    local width=80
    echo -e "${CYAN}╭$(printf '═%.0s' $(seq 1 $width))╮${NC}"
    echo -e "${CYAN}│${NC}                      ${PURPLE}⚡ SNARE OPTIZ ADVANCED MENU ⚡${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}╞$(printf '═%.0s' $(seq 1 $width))╡${NC}"
    echo -e "${CYAN}│${NC}                                                                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[A]${NC} 🎮 Server Profiles                                                           ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}      ${DIM}└─ Specialized optimizations for different server types${NC}                    ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}                                                                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[B]${NC} 📊 Live System Monitor                                                       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}      ${DIM}└─ Real-time performance monitoring with graphs${NC}                           ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}                                                                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[C]${NC} 📝 Generate System Report                                                    ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}      ${DIM}└─ Detailed analysis of system configuration${NC}                             ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}                                                                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[D]${NC} 🔍 System Diagnostics                                                        ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}      ${DIM}└─ Advanced problem detection and analysis${NC}                               ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}                                                                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[F]${NC} 🌐 Network Bandwidth Limiter                                                 ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}      ${DIM}└─ Control and limit network bandwidth using wondershaper${NC}                ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}                                                                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[G]${NC} 💻 CPU Usage Limiter ${PURPLE}[NEW!]${NC}                                                ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}      ${DIM}└─ Control and limit CPU usage per process or system-wide${NC}               ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}                                                                              ${CYAN}│${NC}"
    echo -e "${CYAN}├$(printf '─%.0s' $(seq 1 $width))┤${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[X]${NC} ⬅️  Return to Main Menu                                                       ${CYAN}│${NC}"
    echo -e "${CYAN}╰$(printf '═%.0s' $(seq 1 $width))╯${NC}"
    echo
    echo -ne "${GREEN}Choose an option${NC} ${YELLOW}[A/B/C/D/F/G/X]${NC}: "
}

limit_bandwidth() {
    section_header "NETWORK BANDWIDTH LIMITER"
    
    # Check and install wondershaper if needed
    if ! command -v wondershaper &>/dev/null; then
        info_msg "wondershaper not found. Installing..."
        if command -v apt-get &>/dev/null; then
            apt-get update && apt-get install -y wondershaper
        elif command -v yum &>/dev/null; then
            yum install -y epel-release && yum install -y wondershaper
        elif command -v dnf &>/dev/null; then
            dnf install -y wondershaper
        else
            error_msg "Could not install wondershaper. Please install it manually."
            return
        fi
    fi
    
    # List interfaces with modern UI
    echo -e "${CYAN}╭───────────── Network Interfaces ──────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🌐 ${GREEN}Available interfaces:${NC}"
    interfaces=($(ls /sys/class/net | grep -v lo))
    local i=1
    for iface in "${interfaces[@]}"; do
        echo -e "${CYAN}│${NC}    ${GREEN}[$i]${NC} ${WHITE}$iface${NC}"
        ((i++))
    done
    echo -e "${CYAN}│${NC}    ${RED}[0]${NC} ${WHITE}Cancel${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    echo -ne "\n${GREEN}Select interface${NC} ${YELLOW}[0-$((i-1))]${NC}: "
    read choice
    
    if [[ "$choice" == "0" ]]; then
        return
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#interfaces[@]}" ]; then
        iface="${interfaces[$((choice-1))]}"
    else
        error_msg "Invalid selection"
        return
    fi
    
    # Show bandwidth limit options
    echo -e "\n${CYAN}╭───────────── Bandwidth Limits ───────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🚀 ${GREEN}Select bandwidth limit (down/up):${NC}"
    echo -e "${CYAN}│${NC}    ${GREEN}[1]${NC} ${WHITE}  50 Mbit/s${NC}  ${DIM}(Good for basic usage)${NC}"
    echo -e "${CYAN}│${NC}    ${GREEN}[2]${NC} ${WHITE} 100 Mbit/s${NC}  ${DIM}(Recommended for HD streaming)${NC}"
    echo -e "${CYAN}│${NC}    ${GREEN}[3]${NC} ${WHITE}   1 Gbit/s${NC}  ${DIM}(High-speed connections)${NC}"
    echo -e "${CYAN}│${NC}    ${GREEN}[4]${NC} ${WHITE}   2 Gbit/s${NC}  ${DIM}(Very fast connections)${NC}"
    echo -e "${CYAN}│${NC}    ${GREEN}[5]${NC} ${WHITE}   5 Gbit/s${NC}  ${DIM}(Ultra-fast connections)${NC}"
    echo -e "${CYAN}│${NC}    ${GREEN}[6]${NC} ${WHITE}  10 Gbit/s${NC}  ${DIM}(Enterprise-grade)${NC}"
    echo -e "${CYAN}│${NC}    ${GREEN}[7]${NC} ${WHITE}Custom value${NC} ${DIM}(Enter your own limit)${NC}"
    echo -e "${CYAN}│${NC}    ${GREEN}[8]${NC} ${WHITE}Reset/Remove limit${NC}"
    echo -e "${CYAN}│${NC}    ${RED}[9]${NC} ${WHITE}Cancel${NC}"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    echo -ne "\n${GREEN}Enter your choice${NC} ${YELLOW}[1-9]${NC}: "
    read bw_choice
    
    case $bw_choice in
        1) rate=50 ;;
        2) rate=100 ;;
        3) rate=1000 ;;
        4) rate=2000 ;;
        5) rate=5000 ;;
        6) rate=10000 ;;
        7)
            echo -e "\n${CYAN}╭───────────── Custom Bandwidth ──────────────╮${NC}"
            echo -e "${CYAN}│${NC} 🔢 ${GREEN}Enter bandwidth limit in Mbit/s:${NC}"
            echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
            echo -ne "${GREEN}Value${NC}: "
            read rate
            if ! [[ $rate =~ ^[0-9]+$ ]]; then
                error_msg "Invalid value"
                return
            fi
            ;;
        8)
            wondershaper clear $iface
            success_msg "Bandwidth limit reset for $iface"
            return
            ;;
        9) return ;;
        *) 
            error_msg "Invalid option"
            return 
            ;;
    esac
    
    # Show applying animation
    echo -e "\n${CYAN}╭───────────── Applying Limit ────────────────╮${NC}"
    echo -ne "${CYAN}│${NC} ⚡ ${GREEN}Setting bandwidth limit...${NC}"
    wondershaper -a $iface -d $rate -u $rate
    if [ $? -eq 0 ]; then
        echo -e "\r${CYAN}│${NC} ✅ ${GREEN}Bandwidth limited to $rate Mbit/s on $iface${NC}"
    else
        echo -e "\r${CYAN}│${NC} ❌ ${RED}Failed to set bandwidth limit${NC}"
    fi
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    # Show current status
    echo -e "\n${CYAN}╭───────────── Current Status ────────────────╮${NC}"
    echo -e "${CYAN}│${NC} 📊 ${GREEN}Interface:${NC} $iface"
    echo -e "${CYAN}│${NC} 🔽 ${GREEN}Download limit:${NC} $rate Mbit/s"
    echo -e "${CYAN}│${NC} 🔼 ${GREEN}Upload limit:${NC} $rate Mbit/s"
    echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
    
    echo
    read -p "Press Enter to continue..."
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
    local services=("sshd" "cron")
    for service in "${services[@]}"; do
        if command -v systemctl &>/dev/null && systemctl is-active --quiet $service 2>/dev/null; then
            echo -e "${GREEN}✓ $service is running${NC}"
        elif pgrep -f "$service" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ $service is running${NC}"
        else
            echo -e "${RED}⚠ $service is not running${NC}"
        fi
    done
}

check_cpu_limits() {
    echo -e "\n${GREEN}[6/6] Checking CPU Limits...${NC}"
    if command -v systemctl &> /dev/null; then
        local system_cpu_quota=$(systemctl show system.slice -p CPUQuota --value)
        if [[ -n "$system_cpu_quota" && "$system_cpu_quota" != "0" ]]; then
             echo -e "${GREEN}✓ CPU Limiting is active on system.slice: ${system_cpu_quota}${NC}"
        else
             echo -e "${YELLOW}ℹ No CPU limits are currently active on system.slice${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ systemd not found, cannot check CPU limits.${NC}"
    fi
}

# Function to check if systemd is available
is_systemd_available() {
    if command -v systemctl &>/dev/null && pidof systemd >/dev/null 2>&1; then
        return 0  # systemd is available
    else
        return 1  # systemd is not available
    fi
}

run_diagnostics() {
    clear
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
    echo -e "\n${GREEN}[5/6] Validating System Services...${NC}"
    check_critical_services
    
    # CPU Limit Checks
    check_cpu_limits
    
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
    local critical_services=("sshd" "cron")
    for service in "${critical_services[@]}"; do
        if ! command -v systemctl &>/dev/null || ! systemctl is-active --quiet $service 2>/dev/null; then
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
    local width=70
    echo -e "${CYAN}╭$(printf '═%.0s' $(seq 1 $width))╮${NC}"
    echo -e "${CYAN}│${NC}                     ${PURPLE}⚡ SNARE OPTIZ MENU ⚡${NC}                      ${CYAN}│${NC}"
    echo -e "${CYAN}╞$(printf '═%.0s' $(seq 1 $width))╡${NC}"
    echo -e "${CYAN}│${NC}                                                                    ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[1]${NC} 🚀 Run full optimization ${YELLOW}[Recommended]${NC}                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[2]${NC} 💻 Optimize CPU settings                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[3]${NC} 🎮 Optimize memory settings                                      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[4]${NC} 🌐 Optimize network settings                                     ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[5]${NC} 🔒 Optimize SSH settings                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[6]${NC} ⚡ Setup anti-throttling measures                                ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[7]${NC} 🔍 Optimize DNS settings                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[8]${NC} 🖥️  Install XanMod kernel ${PURPLE}[Separate Installation]${NC}              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[9]${NC} 🔄 Configure BBR options                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[10]${NC} 🕒 Set system timezone                                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[11]${NC} 📊 Show current system status                                  ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${GREEN}[12]${NC} ⚙️  Advanced Options ${PURPLE}[NEW!]${NC}                                   ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}  ${RED}[13]${NC} 🚪 Exit                                                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}                                                                    ${CYAN}│${NC}"
    echo -e "${CYAN}╰$(printf '═%.0s' $(seq 1 $width))╯${NC}"
    echo
    echo -e "${GREEN}Enter your choice${NC} ${YELLOW}[1-13]${NC}: "
}

# Function to check and setup cgroup v2
check_cgroup_v2() {
    # Check if running as root
    if [ "$(id -u)" -ne 0 ]; then
        error_msg "This script must be run as root"
        return 1
    fi

    # Check kernel support
    if ! grep -q "cgroup2" /proc/filesystems; then
        error_msg "cgroup v2 is not available in the kernel"
        return 1
    fi

    # Check if cgroup2 is mounted
    if ! mountpoint -q /sys/fs/cgroup; then
        info_msg "cgroup v2 not mounted. Attempting to mount..."
        
        # Try to unmount any existing cgroup mounts
        if mount | grep -q "type cgroup "; then
            info_msg "Unmounting legacy cgroup mounts..."
            for m in $(mount | grep "type cgroup " | cut -d' ' -f3); do
                umount $m 2>/dev/null
            done
        fi

        # Mount cgroup2
        mkdir -p /sys/fs/cgroup
        mount -t cgroup2 none /sys/fs/cgroup
    fi

    # Verify it's cgroup v2 and not v1
    if ! grep -q "cgroup2" /proc/mounts; then
        error_msg "System is using cgroup v1. Please enable cgroup v2"
        return 1
    fi

    # Check and fix permissions
    if [ ! -w "/sys/fs/cgroup" ]; then
        chmod 755 /sys/fs/cgroup
        if [ ! -w "/sys/fs/cgroup" ]; then
            error_msg "Cannot write to cgroup filesystem"
            return 1
        fi
    fi

    # Create base SNARE OPTIZ directory if it doesn't exist
    local base_dir="/sys/fs/cgroup/snareoptiz"
    if [ ! -d "$base_dir" ]; then
        mkdir -p "$base_dir"
        if [ ! -d "$base_dir" ]; then
            error_msg "Failed to create base cgroup directory"
            return 1
        fi
    fi

    # Enable controllers in root cgroup first
    echo "+cpu +memory" > /sys/fs/cgroup/cgroup.subtree_control
    if [ $? -ne 0 ]; then
        error_msg "Failed to enable controllers in root cgroup"
        return 1
    fi

    # Enable controllers in base directory
    echo "+cpu +memory" > "$base_dir/cgroup.subtree_control"
    if [ $? -ne 0 ]; then
        error_msg "Failed to enable controllers in base directory"
        return 1
    fi

    success_msg "cgroup v2 is properly configured"
    return 0
}

# Function to find all related processes
find_related_processes() {
    local search_term=$1
    local pids=""
    
    # Check if search term is provided
    if [ -z "$search_term" ]; then
        error_msg "Search term is required"
        return 1
    fi
    
    # Find all processes matching the search term
    local matching_pids=$(ps -ef 2>/dev/null | grep "$search_term" | grep -v "grep" | awk '{print $2}' | sort -u)
    
    if [ -z "$matching_pids" ]; then
        error_msg "No processes found matching '$search_term'"
        return 1
    fi
    
    # Add matching PIDs
    pids="$matching_pids"
    
    # Find child processes for each matching PID
    for pid in $matching_pids; do
        if [ -n "$pid" ] && [ "$pid" -gt 0 ]; then
            local child_pids=$(pgrep -P "$pid" 2>/dev/null)
            if [ -n "$child_pids" ]; then
                pids="$pids $child_pids"
            fi
        fi
    done
    
    # Remove duplicates and return
    echo "$pids" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Function to create service cgroup
create_service_cgroup() {
    local service_name=$1
    local cpu_limit=$2
    local mem_limit=$3
    local path="/sys/fs/cgroup/snareoptiz/service_${service_name}"
    
    # Validate inputs
    if [ -z "$service_name" ]; then
        error_msg "Service name is required"
        return 1
    fi
    
    if [ -z "$cpu_limit" ] || ! [[ $cpu_limit =~ ^[0-9]+$ ]]; then
        error_msg "Valid CPU limit is required"
        return 1
    fi
    
    # Create base cgroup
    if ! mkdir -p "$path" 2>/dev/null; then
        error_msg "Failed to create service cgroup directory"
        return 1
    fi
    
    # Enable controllers
    if ! echo "+cpu +memory" > "$path/cgroup.subtree_control" 2>/dev/null; then
        error_msg "Failed to enable controllers in service cgroup"
        rmdir "$path" 2>/dev/null
        return 1
    fi
    
    # Set CPU limit (percentage to microseconds)
    local max_usec=$((1000000 * cpu_limit / 100))
    if ! echo "$max_usec 1000000" > "$path/cpu.max" 2>/dev/null; then
        error_msg "Failed to set CPU limit in service cgroup"
        rmdir "$path" 2>/dev/null
        return 1
    fi
    
    # Set memory limit (in bytes) if provided
    if [ -n "$mem_limit" ]; then
        if ! echo "$((mem_limit * 1024 * 1024 * 1024))" > "$path/memory.max" 2>/dev/null; then
            error_msg "Failed to set memory limit in service cgroup"
            rmdir "$path" 2>/dev/null
            return 1
        fi
    fi
    
    # Find and add all related processes
    local pids=$(find_related_processes "$service_name")
    if [ $? -eq 0 ] && [ -n "$pids" ]; then
        local added_count=0
        for pid in $pids; do
            if [ -n "$pid" ] && [ "$pid" -gt 0 ]; then
                if add_to_cgroup "$path" "$pid"; then
                    ((added_count++))
                fi
            fi
        done
        
        if [ $added_count -gt 0 ]; then
            success_msg "Service '$service_name' limited to ${cpu_limit}% CPU (${added_count} processes)"
        else
            warning_msg "No processes were added to the cgroup"
        fi
    else
        warning_msg "No processes found for service '$service_name'"
    fi
    
    if [ -n "$mem_limit" ]; then
        success_msg "Memory limit set to ${mem_limit}GB"
    fi
    
    return 0
}

# Function to create cgroup
create_cgroup() {
    local name=$1
    local path="/sys/fs/cgroup/snareoptiz/$name"
    
    # Check if directory exists and remove if necessary
    if [ -d "$path" ]; then
        info_msg "Removing existing cgroup..."
        # Move all processes out before removing
        if [ -f "$path/cgroup.procs" ]; then
            while read -r pid; do
                if [ -n "$pid" ]; then
                    echo "$pid" > "/sys/fs/cgroup/snareoptiz/cgroup.procs" 2>/dev/null
                fi
            done < "$path/cgroup.procs"
        fi
        rmdir "$path" 2>/dev/null
    fi
    
    # Create new cgroup
    if ! mkdir -p "$path" 2>/dev/null; then
        error_msg "Failed to create cgroup directory: $path"
        return 1
    fi
    
    # Set permissions
    chmod 755 "$path" 2>/dev/null
    
    # Enable controllers in parent first
    if ! echo "+cpu +memory" > "/sys/fs/cgroup/snareoptiz/cgroup.subtree_control" 2>/dev/null; then
        error_msg "Failed to enable controllers in parent cgroup"
        rmdir "$path" 2>/dev/null
        return 1
    fi
    
    # Enable controllers in new cgroup
    if ! echo "+cpu +memory" > "$path/cgroup.subtree_control" 2>/dev/null; then
        error_msg "Failed to enable controllers in new cgroup"
        rmdir "$path" 2>/dev/null
        return 1
    fi
    
    # Verify controllers are enabled
    if [ ! -f "$path/cpu.max" ] || [ ! -f "$path/memory.max" ]; then
        error_msg "Required controllers not available in cgroup"
        rmdir "$path" 2>/dev/null
        return 1
    fi
    
    echo "$path"
    return 0
}

# Function to set CPU limit using cgroups
set_cgroup_cpu_limit() {
    local path=$1
    local cpu_limit=$2
    
    # Convert percentage to microseconds (1 second = 1000000 microseconds)
    local max_usec=$((1000000 * cpu_limit / 100))
    
    # Set CPU limit with error checking
    if ! echo "$max_usec 1000000" > "$path/cpu.max" 2>/dev/null; then
        error_msg "Failed to set CPU limit"
        return 1
    fi
    
    # Set CPU weight (default: 100, range: 1-10000)
    if ! echo "100" > "$path/cpu.weight" 2>/dev/null; then
        error_msg "Failed to set CPU weight"
        return 1
    fi
    
    return 0
}

# Function to add process to cgroup
add_to_cgroup() {
    local path=$1
    local pid=$2
    
    # Check if cgroup exists
    if [ ! -d "$path" ]; then
        error_msg "Cgroup does not exist: $path"
        return 1
    fi
    
    # Check if process exists
    if ! ps -p "$pid" > /dev/null 2>&1; then
        error_msg "Process $pid does not exist"
        return 1
    fi
    
    # Check if cgroup.procs file exists and is writable
    if [ ! -w "$path/cgroup.procs" ]; then
        error_msg "Cannot write to cgroup.procs in $path"
        return 1
    fi
    
    # Add process to cgroup
    if ! echo "$pid" > "$path/cgroup.procs" 2>/dev/null; then
        error_msg "Failed to add process $pid to cgroup"
        return 1
    fi
    
    return 0
}

# Function to limit CPU usage
limit_cpu_usage() {
    section_header "CPU USAGE LIMITER"
    
    # Check cgroup v2 availability
    if ! check_cgroup_v2; then
        return 1
    fi
    
    # Show profile options with cgroups
    echo -e "${CYAN}╭───────────── Resource Control (cgroups) ────────────╮${NC}"
    echo -e "${CYAN}│${NC} 🖥️  ${GREEN}Select resource control option:${NC}"
    echo -e "${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[1]${NC} Service/Group Control:"
    echo -e "${CYAN}│${NC}    ├─ Limit entire service/process group"
    echo -e "${CYAN}│${NC}    ├─ Automatic process detection"
    echo -e "${CYAN}│${NC}    ├─ Dynamic resource allocation"
    echo -e "${CYAN}│${NC}    └─ Includes child processes"
    echo -e "${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[2]${NC} Workload Profiles:"
    echo -e "${CYAN}│${NC}    ├─ Predefined resource limits"
    echo -e "${CYAN}│${NC}    ├─ Optimized for common scenarios"
    echo -e "${CYAN}│${NC}    ├─ Balanced resource distribution"
    echo -e "${CYAN}│${NC}    └─ Automatic adjustment"
    echo -e "${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}[3]${NC} Custom Resource Control"
    echo -e "${CYAN}│${NC} ${GREEN}[4]${NC} System Protection Limits"
    echo -e "${CYAN}│${NC} ${GREEN}[5]${NC} Remove Resource Limits"
    echo -e "${CYAN}│${NC} ${RED}[6]${NC} Return to Menu"
    echo -e "${CYAN}╰──────────────────────────────────────────────────────╯${NC}"
    
    echo -ne "\n${GREEN}Select profile${NC} ${YELLOW}[1-6]${NC}: "
    read profile_choice
    
    case $profile_choice in
        1)  # Service/Group Control
            echo -e "\n${CYAN}╭───────────── Service/Group Control ────────────────╮${NC}"
            echo -e "${CYAN}│${NC} ${GREEN}Running Services/Processes:${NC}"
            
            # Show running services if systemd is available
            if command -v systemctl >/dev/null 2>&1; then
                echo -e "${CYAN}│${NC} ${YELLOW}Active Services:${NC}"
                systemctl list-units --type=service --state=running | grep ".service" | head -n 5 | \
                    awk '{print "│ " NR ") " $1 " (" $4 ")"}' || echo "│ No active services found"
            fi
            
            # Show top CPU consuming processes
            echo -e "${CYAN}│${NC} ${YELLOW}Top CPU Processes:${NC}"
            ps -eo comm,pid,ppid,pcpu --sort=-pcpu | head -n 6 | tail -n 5 | \
                awk '{printf "│ %d) %s (PID: %s, CPU: %.1f%%)\n", NR, $1, $2, $4}' || echo "│ No processes found"
            
            echo -e "${CYAN}╰──────────────────────────────────────────────────────╯${NC}"
            
            # Get service/process name
            echo -ne "\n${GREEN}Enter service/process name to limit${NC}: "
            read service_name
            
            if [ -z "$service_name" ]; then
                error_msg "Service/process name cannot be empty"
                return
            fi
            
            # Get CPU limit
            echo -ne "${GREEN}Enter CPU limit percentage${NC} ${YELLOW}[1-400]${NC}: "
            read cpu_limit
            
            if ! [[ $cpu_limit =~ ^[0-9]+$ ]] || [ $cpu_limit -lt 1 ] || [ $cpu_limit -gt 400 ]; then
                error_msg "Invalid CPU limit (must be between 1 and 400)"
                return
            fi
            
            # Get memory limit (optional)
            echo -ne "${GREEN}Enter memory limit in GB (optional)${NC} ${YELLOW}[Enter to skip]${NC}: "
            read mem_limit
            
            if [ -n "$mem_limit" ]; then
                if ! [[ $mem_limit =~ ^[0-9]+$ ]] || [ $mem_limit -lt 1 ]; then
                    error_msg "Invalid memory limit"
                    return
                fi
            fi
            
            # Create service cgroup and apply limits
            if create_service_cgroup "$service_name" "$cpu_limit" "$mem_limit"; then
                success_msg "Resource limits applied to '$service_name'"
                
                # Show current resource usage
                echo -e "\n${CYAN}Current Resource Usage:${NC}"
                ps aux | grep "$service_name" | grep -v "grep" | \
                    awk '{cpu+=$3; mem+=$4} END {if(cpu>0 || mem>0) print "CPU: " cpu "%, Memory: " mem "%"; else print "No processes found"}' || echo "No processes found"
            fi
            ;;
            
        2)  # Burstable Profile
            echo -e "\n${CYAN}╭───────────── Burstable Profile ───────────────╮${NC}"
            echo -e "${CYAN}│${NC} ${GREEN}Select resource limit:${NC}"
            echo -e "${CYAN}│${NC} [1] Light    (10% CPU, 1GB RAM)"
            echo -e "${CYAN}│${NC} [2] Basic    (20% CPU, 2GB RAM)"
            echo -e "${CYAN}│${NC} [3] Standard (30% CPU, 4GB RAM)"
            echo -e "${CYAN}│${NC} [4] Enhanced (40% CPU, 8GB RAM)"
            echo -e "${CYAN}│${NC} [5] Premium  (50% CPU, 16GB RAM)"
            echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
            
            echo -ne "\n${GREEN}Select option${NC} ${YELLOW}[1-5]${NC}: "
            read burst_option
            
            case $burst_option in
                1) cpu_limit=10; mem_limit=$((1 * 1024 * 1024 * 1024)) ;;
                2) cpu_limit=20; mem_limit=$((2 * 1024 * 1024 * 1024)) ;;
                3) cpu_limit=30; mem_limit=$((4 * 1024 * 1024 * 1024)) ;;
                4) cpu_limit=40; mem_limit=$((8 * 1024 * 1024 * 1024)) ;;
                5) cpu_limit=50; mem_limit=$((16 * 1024 * 1024 * 1024)) ;;
                *) 
                    error_msg "Invalid selection"
                    return
                    ;;
            esac
            
            # Create cgroup for burstable profile
            cgroup_path=$(create_cgroup "burstable")
            if [ -n "$cgroup_path" ]; then
                set_cgroup_cpu_limit "$cgroup_path" "$cpu_limit"
                echo "$mem_limit" > "$cgroup_path/memory.max"
                add_to_cgroup "$cgroup_path" "$$"
                
                success_msg "Burstable profile activated with ${cpu_limit}% CPU and $(( mem_limit / 1024 / 1024 / 1024 ))GB RAM limit"
            else
                error_msg "Failed to create burstable cgroup"
            fi
            ;;
            
        3)  # Process Group Control
            echo -e "\n${CYAN}╭───────────── Process Group Control ────────────╮${NC}"
            echo -e "${CYAN}│${NC} ${GREEN}Running Processes:${NC}"
            ps aux | grep -v "PID" | awk '{print NR") "$11" (PID: "$2") - CPU: "$3"%, MEM: "$4"%"}' | head -n 10 || echo "│ No processes found"
            echo -e "${CYAN}╰──────────────────────────────────────────────╯${NC}"
            
            echo -ne "\n${GREEN}Enter PID to control${NC}: "
            read target_pid
            
            if ! ps -p $target_pid > /dev/null; then
                error_msg "Invalid PID"
                return
            fi
            
            echo -ne "${GREEN}Enter CPU limit percentage${NC} ${YELLOW}[1-100]${NC}: "
            read cpu_limit
            
            if ! [[ $cpu_limit =~ ^[0-9]+$ ]] || [ $cpu_limit -lt 1 ] || [ $cpu_limit -gt 100 ]; then
                error_msg "Invalid CPU limit"
                return
            fi
            
            echo -ne "${GREEN}Enter memory limit in MB${NC} ${YELLOW}[default: 1024]${NC}: "
            read mem_limit
            mem_limit=${mem_limit:-1024}
            
            # Create cgroup for process
            cgroup_path=$(create_cgroup "proc_${target_pid}")
            if [ -n "$cgroup_path" ]; then
                set_cgroup_cpu_limit "$cgroup_path" "$cpu_limit"
                echo "$((mem_limit * 1024 * 1024))" > "$cgroup_path/memory.max"
                add_to_cgroup "$cgroup_path" "$target_pid"
                
                success_msg "Resource limits applied to PID $target_pid"
            else
                error_msg "Failed to create process cgroup"
            fi
            ;;
            
        4)  # System Protection Limits
            echo -ne "\n${GREEN}Enter system-wide CPU limit percentage${NC} ${YELLOW}[1-100]${NC}: "
            read cpu_limit
            
            if ! [[ $cpu_limit =~ ^[0-9]+$ ]] || [ $cpu_limit -lt 1 ] || [ $cpu_limit -gt 100 ]; then
                error_msg "Invalid CPU limit"
                return
            fi
            
            echo -ne "${GREEN}Enter system-wide memory limit in GB${NC} ${YELLOW}[e.g., 4 or 8, press Enter for no limit]${NC}: "
            read mem_limit

            if [ -n "$mem_limit" ] && ! [[ $mem_limit =~ ^[0-9]+$ ]]; then
                error_msg "Invalid memory limit"
                return
            fi

            info_msg "Applying system-wide resource limits by creating systemd drop-in files..."

            # Define drop-in file content
            local drop_in_content="[Slice]\nCPUQuota=${cpu_limit}%\n"
            if [ -n "$mem_limit" ]; then
                drop_in_content+="MemoryMax=${mem_limit}G\n"
            fi

            # Create drop-in files for system.slice and user.slice
            mkdir -p /etc/systemd/system/system.slice.d
            mkdir -p /etc/systemd/system/user.slice.d
            echo -e "$drop_in_content" > /etc/systemd/system/system.slice.d/99-snare-optiz.conf
            echo -e "$drop_in_content" > /etc/systemd/system/user.slice.d/99-snare-optiz.conf
            
            # Reload systemd to make it aware of the new files
            systemctl daemon-reload
            
            # Apply properties to the running system immediately to avoid a reboot
            info_msg "Applying live resource limits..."
            systemctl set-property system.slice "CPUQuota=${cpu_limit}%"
            systemctl set-property user.slice "CPUQuota=${cpu_limit}%"

            if [ -n "$mem_limit" ]; then
                systemctl set-property system.slice "MemoryMax=${mem_limit}G"
                systemctl set-property user.slice "MemoryMax=${mem_limit}G"
            else
                # Unset memory limit if not provided
                systemctl set-property system.slice MemoryMax=infinity
                systemctl set-property user.slice MemoryMax=infinity
            fi
            
            success_msg "System-wide resource limits applied and will persist across reboots."
            info_msg "CPUQuota=${cpu_limit}% | MemoryMax=${mem_limit:-Unlimited}G"
            ;;
            
        5)  # Remove Resource Limits
            info_msg "Removing all system-wide resource limits..."

            # Remove drop-in files
            rm -f /etc/systemd/system/system.slice.d/99-snare-optiz.conf
            rm -f /etc/systemd/system/user.slice.d/99-snare-optiz.conf

            # Reload systemd to unapply settings
            systemctl daemon-reload
            
            # Reset properties on the running system
            systemctl set-property system.slice CPUQuota="" MemoryMax=""
            systemctl set-property user.slice CPUQuota="" MemoryMax=""

            # Also remove custom cgroups from previous versions of the script
            for cgroup in /sys/fs/cgroup/snareoptiz/*; do
                if [ -d "$cgroup" ] && [ "$(basename "$cgroup")" != "snareoptiz" ]; then
                    # Move processes out before removing cgroup
                    if [ -f "$cgroup/cgroup.procs" ]; then
                       cat "$cgroup/cgroup.procs" | while read -r pid; do
                           echo "$pid" > /sys/fs/cgroup/cgroup.procs 2>/dev/null
                       done
                    fi
                    rmdir "$cgroup" 2>/dev/null
                fi
            done
            info_msg "Cleaned up old custom cgroups."
            
            # Delete old service if it exists
            if systemctl --all --type=service | grep -q "system-resource-limit.service"; then
                systemctl stop system-resource-limit.service
                systemctl disable system-resource-limit.service
                rm -f /etc/systemd/system/system-resource-limit.service
                systemctl daemon-reload
                info_msg "Removed old system-resource-limit.service"
            fi

            success_msg "All system-wide resource limits have been removed."
            ;;
            
        6)  # Return to menu
            return
            ;;
            
        *)
            error_msg "Invalid option"
            return
            ;;
    esac
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
                    G) limit_cpu_usage ;;
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