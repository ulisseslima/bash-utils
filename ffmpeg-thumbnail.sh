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
resize=720

while test $# -gt 0
do
    case "$1" in
        --out|-o)
	    shift
            out="$1"
        ;;
        --resize)
            shift
	    resize=$1
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

ffmpeg -v 16 -y -i "$video" -ss $frame -frames:v 1 "$out"

height=$(file "$out" | cut -d' ' -f7 | tr -d ',')
if [[ "$height" != "$resize"  ]]; then
	redim="$video_dir/thumb-${frame}-${resize}p.png"
	convert -resize x${resize} "$out" "$redim"
	>&2 echo "${resize}p: $redim"
fi

echo "$redim"
