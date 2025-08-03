#!/bin/bash

# Get the clipboard content
url=$(xclip -o -selection clipboard)

yt-dlp -f "best[height<=1080]" "$url" -o '~/Downloads/Videos/%(title)s.%(ext)s'
