#!/bin/bash
# flips a video horizontally or vertically

source $(real require.sh)

input="$1"
require -f input

orientation=$2
require --in 'h v' orientation

ffmpeg -i "$input" -vf ${orientation}flip -c:a copy "${input}-flip${orientation}.mp4"

