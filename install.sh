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
mkdir -p /opt/server-optimizer

# Check for local file first
echo "Looking for server_optimizer.sh..."
if [ -f "server_optimizer.sh" ]; then
    echo "Found local server_optimizer.sh file."
    cp server_optimizer.sh /opt/server-optimizer/server_optimizer.sh
    echo "Copied to installation directory."
else
    echo "Local file not found. Checking GitHub..."
    if curl -s -f -o /opt/server-optimizer/server_optimizer.sh https://raw.githubusercontent.com/snarefps/SNAREOPTIZ/main/mainscript.sh; then
        echo "Download successful!"
    else
        echo "Error: Could not find server_optimizer.sh. Installation failed."
        echo "Please make sure the file exists in the current directory or in the GitHub repository."
        exit 1
    fi
fi

# Make script executable
chmod +x /opt/server-optimizer/server_optimizer.sh

# Create symlink for easy access
ln -sf /opt/server-optimizer/server_optimizer.sh /usr/local/bin/optiz

# Check for required dependencies
echo "Checking dependencies..."
DEPS=("bc" "curl" "grep" "awk" "sed")
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
        apt-get update
        apt-get install -y ${MISSING[@]}
    elif command -v yum &> /dev/null; then
        yum install -y ${MISSING[@]}
    else
        echo "Warning: Could not install missing dependencies. Please install them manually."
    fi
fi

echo "Installation complete!"
echo "You can now run the optimization script with: sudo optiz"
echo "Or from its location: sudo /opt/server-optimizer/server_optimizer.sh"