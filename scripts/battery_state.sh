#!/bin/bash

# Get battery percentage
battery_level=$(cat /sys/class/power_supply/BAT0/capacity)

# Get battery status (Charging/Discharging)
battery_status=$(cat /sys/class/power_supply/BAT0/status)

# Determine the battery icon based on the level and status
if [ "$battery_status" = "Charging" ]; then
  if [ "$battery_level" -ge 90 ]; then
    echo "󰂅 " # Full and Charging
  elif [ "$battery_level" -ge 60 ]; then
    echo "󰂉 " # Medium and Charging
  elif [ "$battery_level" -ge 30 ]; then
    echo "󰂇 " # Low and Charging
  else
    echo "󰢜 " # Very Low and Charging
  fi
else
  if [ "$battery_level" -ge 90 ]; then
    echo "󰁹" # Full
  elif [ "$battery_level" -ge 60 ]; then
    echo "󰁿" # Medium
  elif [ "$battery_level" -ge 30 ]; then
    echo "󰁼" # Low
  else
    echo " " # Very Low
  fi
fi
