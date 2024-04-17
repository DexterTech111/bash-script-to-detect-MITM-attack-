#!/bin/bash

# Function to print usage instructions
print_usage() {
    echo "Usage: $0 <interface_name>"
    echo "Example: $0 eth0"
}

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Check if the required number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Error: Invalid number of arguments."
    print_usage
    exit 1
fi

interface_name="$1"

# Check if the provided interface is valid
if ! ip link show "$interface_name" >/dev/null 2>&1; then
    echo "Error: Invalid interface name."
    print_usage
    exit 1
fi

# Function to get MAC address
get_mac_address() {
    local ip="$1"
    local iface="$2"
    arp -a -i "$iface" | awk -v ip="$ip" '$2 ~ ip {print $4}'
}

# Introduction
echo "Welcome to MITM detect script!"
echo

# Find Router's IP Address
routers_ip=$(route -n | awk '/UG/ {print $2}')

echo "Router's IP        : $routers_ip"

# Find Router's First MAC Address
first_mac_ap=$(get_mac_address "$routers_ip" "$interface_name")

echo "Router's First MAC : $first_mac_ap"

# Infinite loop to continuously monitor for ARP spoofing
detected=0

while true; do
    # Check Router's MAC Address Again
    second_mac_ap=$(get_mac_address "$routers_ip" "$interface_name")

    if [ "$second_mac_ap" != "$first_mac_ap" ]; then
        detected=1
        break
    fi

    # Sleep for a short duration before checking again (e.g., 1 second)
    sleep 1
done

echo "Router's Second MAC : $second_mac_ap"

detect_date=$(date)
echo "Detect Date is      : $detect_date"

# Save results to a file
cat > Results.txt <<EOF
Router's IP        : $routers_ip
Router's First MAC : $first_mac_ap
Message            : Warning: The router's first MAC is different than the second MAC. Please be careful about MITM attack. Check Results.txt for more information
Detect Date is     : $detect_date
EOF

echo

if [ $detected -eq 1 ]; then
    echo "Warning: The router's first MAC is different than the second MAC. Please be careful about MITM attack. Check Results.txt for more information."
else
    echo "No ARP spoofing detected. Check Results.txt for more information."
fi

# Sleep for 3 seconds before running the Python script
echo "Waiting 3 seconds before running Python script..."
sleep 3

# Run your Python script here
python mailer.py
