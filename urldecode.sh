#!/bin/bash

# Check if the user supplied an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <url_encoded_string>"
    exit 1
fi

# Function to URL decode using printf
url_decode() {
    local url_encoded=${1//+/ } # Plus (+) signs usually represent spaces
    printf '%b' "${url_encoded//%/\\x}"
}

# Decode and output the decoded URL
url_decode "$1"
echo
