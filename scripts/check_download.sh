#!/bin/bash

# Path to the status file
STATUS_FILE="$HOME/.status_yt-dlp"

# Icon codes (use appropriate codes for your font)
ICON_DOWNLOADING="󰇚" # Example icon for downloading
ICON_IDLE=""         # No icon for idle state

# Check if yt-dlp is running
if pgrep -x "yt-dlp" >/dev/null; then
  echo "$ICON_DOWNLOADING"
else
  echo "$ICON_IDLE"
fi
