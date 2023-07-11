#!/bin/bash
# adds an audio file to a video file, resulting in a new video
source $(real require.sh)
source $(real log.sh)

function audio() {
    video="$1"
    audio="$2"
    out="$3"

    info "adding audio [$audio] to video [$video] ..."
    ffmpeg <&1- -v 16 -i "$video" -i "$audio" -map 0:v -map 1:a -c:v copy -shortest "$out" > /dev/null
    require -f out
}

audio "$@"
