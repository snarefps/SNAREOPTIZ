# Linux Server Optimization Script

This script optimizes Linux servers for high-performance workloads, especially for servers running CPU-intensive tasks and SSH tunnels.

## Features

- **CPU Optimization**: Sets CPU governor to performance mode and optimizes scheduler
- **Memory Management**: Configures swappiness, cache pressure, and disables transparent hugepages
- **Network Tuning**: Enables BBR congestion control and optimizes TCP/IP stack
- **SSH Tunnel Optimization**: Configures SSH for better tunnel performance
- **Anti-Throttling Measures**: Detects and prevents CPU throttling by data centers

## Requirements

- Root access to the server
- Linux-based operating system (Debian/Ubuntu or CentOS/RHEL)
- Basic packages: `bc`, `cpulimit` (will be installed if missing)

## Usage

1. Upload the script to your server:
   ```
   scp server_optimizer.sh user@your-server:/tmp/
   ```

2. Connect to your server and make the script executable:
   ```
   chmod +x /tmp/server_optimizer.sh
   ```

3. Run the script as root:
   ```
   sudo /tmp/server_optimizer.sh
   ```

4. Reboot your server when possible to apply all changes:
   ```
   sudo reboot
   ```

## What the Script Does

1. **CPU Optimization**
   - Sets CPU governor to performance mode
   - Optimizes kernel scheduler parameters
   - Disables CPU throttling

2. **Memory Optimization**
   - Reduces swappiness for better performance
   - Optimizes cache pressure
   - Disables transparent hugepages

3. **Network Optimization**
   - Enables BBR congestion control algorithm
   - Increases network buffer sizes
   - Optimizes TCP parameters

4. **SSH Tunnel Optimization**
   - Configures keep-alive settings
   - Enables compression
   - Increases max sessions

5. **Anti-Throttling Measures**
   - Monitors CPU usage
   - Automatically manages process priorities
   - Limits CPU usage of processes that might trigger throttling

## Warning

This script makes significant changes to system settings. It's recommended to:
- Test in a non-production environment first
- Create a backup or snapshot before running
- Monitor system performance after applying changes

## Customization

You can modify the script to adjust thresholds and settings based on your specific needs. 