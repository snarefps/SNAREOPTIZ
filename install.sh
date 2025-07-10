#!/bin/bash

# Installation script for server optimizer
# This script installs the server optimization script

echo "Server Optimizer Installation Script"
echo "==================================="

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Create directory for scripts
mkdir -p /opt/snareoptiz

# Check for local file first
echo "Looking for mainscript.sh..."
if [ -f "mainscript.sh" ]; then
    echo "Found local snareoptiz file."
    cp mainscript.sh /opt/snareoptiz/mainscript.sh
    echo "Copied to installation directory."
else
    echo "Local file not found. Checking GitHub..."
    if curl -s -f -o /opt/snareoptiz/mainscript.sh https://raw.githubusercontent.com/snarefps/SNAREOPTIZ/main/mainscript.sh; then
        echo "Download successful!"
    else
        echo "Error: Could not find mainscript.sh. Installation failed."
        echo "Please make sure the file exists in the current directory or in the GitHub repository."
        exit 1
    fi
fi

# Make script executable
chmod +x /opt/snareoptiz/mainscript.sh

# Create symlink for easy access
ln -sf /opt/snareoptiz/mainscript.sh /usr/local/bin/optiz

# Update system packages
echo "Updating system packages..."
if command -v apt-get &> /dev/null; then
    echo "Using apt package manager..."
    apt-get update
    apt-get upgrade -y
    apt-get dist-upgrade -y
elif command -v yum &> /dev/null; then
    echo "Using yum package manager..."
    yum update -y
elif command -v dnf &> /dev/null; then
    echo "Using dnf package manager..."
    dnf update -y
else
    echo "Warning: No supported package manager found."
fi

# Check for required dependencies
echo "Checking dependencies..."
DEPS=("bc" "curl" "grep" "awk" "sed" "wget" "unzip" "net-tools" "sysstat" "cpulimit")
MISSING=()

for dep in "${DEPS[@]}"; do
    if ! command -v $dep &> /dev/null; then
        MISSING+=("$dep")
    fi
done

# Install missing dependencies
if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Installing missing dependencies: ${MISSING[*]}"
    if command -v apt-get &> /dev/null; then
        apt-get install -y ${MISSING[@]}
    elif command -v yum &> /dev/null; then
        yum install -y ${MISSING[@]}
    elif command -v dnf &> /dev/null; then
        dnf install -y ${MISSING[@]}
    else
        echo "Warning: Could not install missing dependencies. Please install them manually."
    fi
fi

# Install additional useful packages for server optimization
echo "Installing additional optimization packages..."
ADDITIONAL_PACKAGES=("htop" "iotop" "nethogs" "iftop" "nload" "speedtest-cli" "stress" "sysbench")
for pkg in "${ADDITIONAL_PACKAGES[@]}"; do
    if command -v apt-get &> /dev/null; then
        apt-get install -y $pkg 2>/dev/null || echo "Package $pkg not available in apt repositories"
    elif command -v yum &> /dev/null; then
        yum install -y $pkg 2>/dev/null || echo "Package $pkg not available in yum repositories"
    elif command -v dnf &> /dev/null; then
        dnf install -y $pkg 2>/dev/null || echo "Package $pkg not available in dnf repositories"
    fi
done

echo "Installation complete!"
echo "You can now run the optimization script with: sudo optiz"
echo "Or from its location: sudo /opt/snareoptiz/mainscript.sh"