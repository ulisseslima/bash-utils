#!/bin/bash
# https://stackoverflow.com/questions/53374590/ffmpeg-change-tone-frequency-keep-length-pitch-audio

source $(real require.sh)

in="$1"
require -f in

pitch=$2
require pitch

# good pitches between 0.9 and 1.2
ffmpeg -i "$in" -af asetrate=44100*$pitch,aresample=44100,atempo=1/$pitch "$(dirname "$in")/pitch${pitch}.$(basename "${in}")"

