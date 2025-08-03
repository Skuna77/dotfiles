#!/bin/bash

# Configuration
NET_INTERFACES=("wlp1s0")  # Add your interfaces here
STATE_FILE="/tmp/system_status_state"
SAMPLE_INTERVAL=1  # Seconds for network speed calculation

# Initialize or read previous state
if [[ ! -f "$STATE_FILE" ]]; then
    declare -A PREV_RX PREV_TX
    for intf in "${NET_INTERFACES[@]}"; do
        PREV_RX[$intf]=0
        PREV_TX[$intf]=0
    done
    echo "0 ${!PREV_RX[@]}" > "$STATE_FILE"
    for intf in "${NET_INTERFACES[@]}"; do
        echo "$intf 0 0" >> "$STATE_FILE"
    done
else
    mapfile -t state_lines < "$STATE_FILE"
    last_run=${state_lines[0]%% *}
    interfaces=(${state_lines[0]#* })
    declare -A PREV_RX PREV_TX
    for ((i=1; i<${#state_lines[@]}; i++)); do
        read -r iface prev_rx prev_tx <<< "${state_lines[$i]}"
        PREV_RX[$iface]=$prev_rx
        PREV_TX[$iface]=$prev_tx
    done
fi

# Get current timestamp
current_time=$(date +"%a %Y-%m-%d %H:%M:%S")

# CPU Usage (percentage)
read -r -a cpu_stats <<< "$(grep '^cpu ' /proc/stat)"
total_cpu=$(( ${cpu_stats[1]} + ${cpu_stats[2]} + ${cpu_stats[3]} + ${cpu_stats[4]} + \
              ${cpu_stats[5]} + ${cpu_stats[6]} + ${cpu_stats[7]} ))
idle_cpu=${cpu_stats[4]}
cpu_percent=$(( (100 * (total_cpu - idle_cpu)) / total_cpu ))

# CPU Temperature (Celsius)
temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
cpu_temp=$([[ -n $temp ]] && echo $((temp / 1000)) || echo "N/A")

# RAM Usage (percentage) - FIXED: Extract numeric values only
mem_total=$(grep -m1 'MemTotal' /proc/meminfo | awk '{print $2}')
mem_avail=$(grep -m1 'MemAvailable' /proc/meminfo | awk '{print $2}')
ram_percent=$(( (mem_total - mem_avail) * 100 / mem_total ))

# Battery Percentage
battery=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")

# Volume Percentage
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -n1 | tr -d '%' || echo "N/A")

# Network speeds
declare -A RX_SPEED TX_SPEED
for intf in "${NET_INTERFACES[@]}"; do
    rx_path="/sys/class/net/$intf/statistics/rx_bytes"
    tx_path="/sys/class/net/$intf/statistics/tx_bytes"
    
    if [[ -f "$rx_path" && -f "$tx_path" ]]; then
        rx_current=$(cat "$rx_path")
        tx_current=$(cat "$tx_path")
        
        rx_diff=$((rx_current - ${PREV_RX[$intf]}))
        tx_diff=$((tx_current - ${PREV_TX[$intf]}))
        
        RX_SPEED[$intf]=$((rx_diff / SAMPLE_INTERVAL))
        TX_SPEED[$intf]=$((tx_diff / SAMPLE_INTERVAL))
        
        # Update previous values
        PREV_RX[$intf]=$rx_current
        PREV_TX[$intf]=$tx_current
    else
        RX_SPEED[$intf]=0
        TX_SPEED[$intf]=0
    fi
done

# Format network speeds
format_speed() {
    local speed=$1
    if (( speed > 1000000 )); then
        printf "%.1fM" "$(bc <<< "scale=2; $speed / 1000000")"
    elif (( speed > 1000 )); then
        printf "%.0fK" "$((speed / 1000))"
    else
        printf "%d" "$speed"
    fi
}

# Prepare network output
network_output=""
for intf in "${NET_INTERFACES[@]}"; do
    rx_fmt=$(format_speed "${RX_SPEED[$intf]}")
    tx_fmt=$(format_speed "${TX_SPEED[$intf]}")
    network_output+=" | ${intf}:↑${tx_fmt} ↓${rx_fmt}"
done

# Update state file
echo "$(date +%s) ${NET_INTERFACES[*]}" > "$STATE_FILE"
for intf in "${NET_INTERFACES[@]}"; do
    echo "$intf ${PREV_RX[$intf]} ${PREV_TX[$intf]}" >> "$STATE_FILE"
done

# Final output
echo "${current_time} | CPU:${cpu_percent}% ${cpu_temp}°C | RAM:${ram_percent}% | BAT:${battery}% | VOL:${volume}%${network_output}"
