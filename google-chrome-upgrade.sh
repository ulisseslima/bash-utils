#!/bin/bash
# https://www.google.com/chrome/next-steps.html?statcb=0&installdataindex=empty&defaultbrowser=0#

source $(real require.sh)

url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
name=$(basename "$url")

destination="/tmp/$name"

curl --output "$destination" "$url"
require -f destination "$name download"

killall chrome

sudo dpkg -i "$destination"

google-chrome &
