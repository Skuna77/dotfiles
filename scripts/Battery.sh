#!/bin/bash
# Get battery icons
CHARGING_ICON="/home/geto/Downloads/icons/charging.png"
DISCHARGING_ICON="/home/geto/Downloads/icons/discharging.png"
FULL_ICON="/home/geto/Downloads/icons/fullbattery.png"
LOW_BATTERY_ICON="/home/geto/Downloads/icons/lowbattery.png"
DEAD_BATTERY_ICON="/home/geto/Downloads/icons/deadbattery.png"


# Get battery status
BATTERY_STATUS=$(acpi -b | grep -oP 'Charging|Discharging')
BATTERY_PERCENT=$(acpi -b | grep -oP '[0-9]+(?=%)')
BATTERY_TIME=$(acpi -b | grep -oP '[0-9]{2}:[0-9]{2}:[0-9]{2}')

if [[ "$BATTERY_STATUS" == "Charging" && "$BATTERY_PERCENT" -ge 99 ]]; then
    # Notify when battery is full
    dunstify -i "$FULL_ICON" "Battery Full" "Battery is fully charged." && paplay "/home/geto/Downloads/Audio/fullbattery.wav"
elif [[ "$BATTERY_STATUS" == "Discharging" && "$BATTERY_PERCENT" -le 10 ]]; then
    # Notify when battery is low
   dunstify -i "$DEAD_BATTERY_ICON" "Dead Battery" "Battery is very low ($BATTERY_PERCENT%)." && paplay "/home/geto/Downloads/Audio/deadbattery.wav"
elif [[ "$BATTERY_STATUS" == "Discharging" && "$BATTERY_PERCENT" -le 20 ]]; then
    # Notify when battery is dead
    dunstify -i "$LOW_BATTERY_ICON" "Low Battery" "Battery is low ($BATTERY_PERCENT%)." && mpv "/home/geto/Downloads/Audio/lowbattery.webm" 
fi


