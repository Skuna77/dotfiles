#!/bin/bash

# get volume per
volume=$(pamixer --get-volume)
if [ "$volume" -ge 70 ]; then
  echo "󰕾 $volume%"
elif [ "$volume" -ge 10 ]; then
  echo "󰖀 $volume%"
elif [ "$volume" -eq 0 ]; then
  echo "󰝟"
else
  echo "󰕿 $volume%"
fi
