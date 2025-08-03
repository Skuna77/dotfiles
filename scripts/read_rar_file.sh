#!/bin/bash

# Check if unrar is installed
if ! command -v unrar &> /dev/null; then
    echo "unrar is not installed. Please install it first using: sudo pacman -S unrar"
    exit 1
fi

# Check if rar file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <file.rar>"
    exit 1
fi

# List the contents of the rar file
echo "Listing files inside $1:"
unrar l "$1" | awk 'NR>7 {print $NF}' | sed '/^$/d'

# Prompt the user for the file to read
read -p "Enter the name of the file you want to read: " file_to_read

# Create a temporary directory for extraction
temp_dir=$(mktemp -d)

# Extract the specific file to the temporary directory
unrar e "$1" "$file_to_read" "$temp_dir" &> /dev/null

# Check if the file was successfully extracted
if [ -f "$temp_dir/$file_to_read" ]; then
    # Display the file contents
    echo "Displaying contents of $file_to_read:"
    cat "$temp_dir/$file_to_read"
    
    # Optionally remove the extracted file
    rm -rf "$temp_dir"
else
    echo "File $file_to_read not found in the archive."
fi

