#!/bin/sh

# List active network interfaces
interface=$(ip link show | awk -F ': ' '/state UP/ {print $2; exit}')
[ -z "$interface" ] && exit 1  # Exit if no active interface is found

# Validate if the detected interface has statistics
if [ ! -f "/sys/class/net/$interface/statistics/rx_bytes" ]; then
    echo "Error: Could not find statistics for interface $interface"
    exit 1
fi

# Get initial byte counts
rx1=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx1=$(cat /sys/class/net/$interface/statistics/tx_bytes)
sleep 1
rx2=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx2=$(cat /sys/class/net/$interface/statistics/tx_bytes)

# Calculate speeds in MB/s
rx_rate=$(awk "BEGIN {print ($rx2 - $rx1) / 1024 / 1024}")
tx_rate=$(awk "BEGIN {print ($tx2 - $tx1) / 1024 / 1024}")

# Display the results
printf "▼ %.1fM ▲ %.1fM\n" "$rx_rate" "$tx_rate"

