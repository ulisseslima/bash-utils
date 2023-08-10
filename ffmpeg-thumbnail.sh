#!/bin/bash
# extracts a frame to create a video thumbnail
# http://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video
source $(real require.sh)

video="$1"
require -f video
video=$(readlink -f "$video")

frame="$2"
require frame 'desired timestamp. e.g.: 00:00:14.435'

video_dir=$(dirname "$video")

out="$video_dir/thumb-$frame.png"
ffmpeg -i "$video" -ss $frame -frames:v 1 "$out"

height=720
redim="$video_dir/thumb-${frame}-${height}p.png"
convert -resize x${height} "$out" "$redim"

echo "$redim"
