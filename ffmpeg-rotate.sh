#!/bin/bash
# rotates a video without reencoding (metadata only)

source $(real require.sh)

input="$1"
require -f input

degrees=$2
require -nx degrees

#ffmpeg -i "$input" -metadata:s:v rotate="$degrees" -c:v copy -c:a copy "${input}-rotate${degrees}.mp4"
ffmpeg -i "$input" -vf "transpose=$degrees" -c:a copy "${input}-rotate${degrees}.mp4"


