#!/bin/bash

# Get the clipboard content
url=$(xclip -selection clipboard -o)

yt-dlp -f "bestaudio" "$url" -o '~/Downloads/Audio/%(title)s.%(ext)s'
