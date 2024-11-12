#!/bin/bash
# https://stackoverflow.com/questions/7333232/how-to-concatenate-two-mp4-files-using-ffmpeg
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"

start_dir=${1:-$MYDIR}
pattern=${2:-.mp4}

ffmpeg -safe 0 -f concat -i <(find $start_dir -type f -name *"$pattern" -printf "file '$PWD/%p'\n" | sort) -c copy "result${pattern}"
