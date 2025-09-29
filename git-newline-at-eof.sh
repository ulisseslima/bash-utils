#!/bin/bash
# Usage: ./add_final_newline.sh filename
#- Checks if the input file was provided and exists.
#- Only operates if the file is non-empty (`-s` test).
#- Uses `tail -c1` to get the last byte, and checks if it's a newline (`0a` in hex).
#- If not, appends a newline.

FILE="$1"

if [[ -z "$FILE" ]]; then
    echo "Usage: $0 filename"
    exit 1
fi

# Check if the file exists
if [[ ! -f "$FILE" ]]; then
    echo "File not found: $FILE"
    exit 1
fi

# Check last character of the file
if [[ -s "$FILE" && $(tail -c1 "$FILE" | od -An -tx1 | tr -d ' \n') != "0a" ]]; then
    echo >> "$FILE"
fi
