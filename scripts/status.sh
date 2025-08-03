#!/usr/bin/env bash

# Network Section
wlan_speed() {
    interface="wlp1s0"
    if [ -d "/sys/class/net/$interface" ]; then
        rx_prev=$(cat /tmp/wlan_rx_prev 2>/dev/null || echo 0)
        tx_prev=$(cat /tmp/wlan_tx_prev 2>/dev/null || echo 0)
        
        rx_current=$(cat "/sys/class/net/$interface/statistics/rx_bytes")
        tx_current=$(cat "/sys/class/net/$interface/statistics/tx_bytes")
        
        echo "$rx_current" > /tmp/wlan_rx_prev
        echo "$tx_current" > /tmp/wlan_tx_prev
        
        printf " %d↓ %d↑" "$(( (rx_current - rx_prev) / 1024 ))" "$(( (tx_current - tx_prev) / 1024 ))"
    fi
}

is_ethernet_connected() {
    # Change eth0 to your Ethernet interface name if needed
    for iface in /sys/class/net/*; do
        if [[ -f "$iface/type" && "$(cat "$iface/type")" -eq 1 ]]; then
            # Skip wireless interfaces (type 1 is Ethernet)
            name=$(basename "$iface")
            if [[ "$name" != lo && -e "$iface/carrier" ]]; then
                if [[ "$(cat "$iface/carrier")" -eq 1 ]]; then
                    echo "yes"
                    printf ""
                fi
            fi
        fi
    done
}


# Hardware Monitoring
cpu_temp() {
    temp=$(sensors | grep -m 1 'Core 0' | awk '{print $3}')
 
    printf " %s" "$temp"
}

cpu_per()
{
  read -r -a cpu_stats <<< "$(grep '^cpu ' /proc/stat)"
total_cpu=$(( ${cpu_stats[1]} + ${cpu_stats[2]} + ${cpu_stats[3]} + ${cpu_stats[4]} + \
              ${cpu_stats[5]} + ${cpu_stats[6]} + ${cpu_stats[7]} ))
idle_cpu=${cpu_stats[4]}
cpu_percent=$(( (100 * (total_cpu - idle_cpu)) / total_cpu ))
printf "  %s%%" "$cpu_percent"
}


ram_usage() {
    free | awk '/Mem/ {printf " %.1f%%", $3/$2 * 100}'
}

battery_status() {
    bat=$(ls /sys/class/power_supply | grep -i BAT)
    if [ -n "$bat" ]; then
        capacity=$(cat /sys/class/power_supply/$bat/capacity)
        status=$(cat /sys/class/power_supply/$bat/status)
        case $status in
            "Charging") icon="" ;;
            *) icon="" ;;
        esac
        printf "%s %d%%" "$icon" "$capacity"
    else
        printf " AC"
    fi
}

# Audio (Fixed percentage display)
volume_level() {
    vol=$(amixer get Master 2>/dev/null | awk -F'[][]' '/%/ {print $2}' | head -1)
    [ -z "$vol" ] && vol=$(pactl list sinks 2>/dev/null | awk '/Volume:/ {print $5}' | head -1)
    printf " %s" "${vol:-N/A}"
}

# Date/Time
datetime() {
    printf " %s  %s" "$(date "+%a %d %b")" "$(date "+%H:%M")"
}

# Build the status line
status_parts=(
    "$(datetime)"
    "$(wlan_speed)"
   # "$(is_ethernet_connected)"
    "$(cpu_per)"
    "$(cpu_temp)"
    "$(ram_usage)"
    "$(battery_status)"
    "$(volume_level)"
)

# Filter empty elements and join with separators
final_status=""
for part in "${status_parts[@]}"; do
    [ -n "$part" ] && final_status+="  ${part}"
done

echo "${final_status#  }"
