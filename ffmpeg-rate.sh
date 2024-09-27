#!/bin/bash
# https://superuser.com/questions/1261678/how-do-i-speed-up-a-video-by-60x-in-ffmpeg
source $(real require.sh)

input="$1"
require -f input
shift

rate="$1"
require rate "to speed up 2x: '/2'; to slow down 2x: '*2'"
shift

overwrite=false
fname=$(basename "$input")
fdir=$(dirname "$input")

out="${fdir}/new-rate_${fname}"

while test $# -gt 0
do
    case "$1" in
        --out|-o)
	    shift
            out="$1"
        ;;
        --overwrite|-y)
            overwrite=true
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

if [[ -f "$out" && $overwrite == false ]]; then
        >&2 echo "already exists: $out"
        exit 0
fi

ffmpeg -y -i "$input" -filter:v "setpts=PTS${rate}" "$out"
