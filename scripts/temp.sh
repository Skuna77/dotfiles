#!/bin/bash

# Check if 'sensors' is installed
if ! command -v sensors &> /dev/null; then
  echo "Error: 'sensors' command not found. Please install lm-sensors."
  exit 1
fi

# Get CPU temperature
temperature=$(sensors | grep 'Core 0' | awk '{print $3}' | sed 's/+//;s/°C//')

# Output the temperature
echo "${temperature}°C"
