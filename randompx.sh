#!/bin/bash
# creates a random image file

mx=${1:-320}; my=${2:-240}
rfile=${3:-img.jpg}

echo "creating $rfile file with ${mx}x${my}"

head -c "$((3*mx*my))" /dev/urandom | convert -depth 8 -size "${mx}x${my}" RGB:- "$rfile"
