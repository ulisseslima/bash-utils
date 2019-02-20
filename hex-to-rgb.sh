#!/bin/bash

# hex html color to rgb

hex="$1"

r="${hex:1:2}"
g="${hex:3:2}"
b="${hex:5:2}"

echo "rgb($((16#$r)), $((16#$g)), $((16#$b)))"
