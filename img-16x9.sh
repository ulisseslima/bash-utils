#!/bin/bash
# changes the input image to 16:9 aspect

source $(real require.sh)

input="$1"
require -f input
inputn=$(basename "$input")

bg_strategy=predominant

while test $# -gt 0
do
    case "$1" in
        --out|-o)
            shift
	        out="$1"
        ;;
        --bg)
            shift
	        bg_strategy="$1"
	        # require --in 'top-left-pixel predominant-pixel' bg_strategy
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

height=$(ffmpeg-info.sh "$input" --height)
width=$(op.sh "((16.0/9.0)*${height})::int")

case "$bg_strategy" in
    top-left*)
        color=$(convert "$input" -colorspace rgb -format "%[pixel:p{0,0}]" info:)
    ;;
    predominant*)
        color=$(convert "$input" -colors 1 -format "%c" histogram:info:- | sed -n 's/^[ ]*\(.*\):.*[#]\(.*\)$/\2/p' | head -n 1 | cut -d' ' -f2)
    ;;
    *)
        echo "unrecognized strategy: $bg_strategy"
        exit 1
    ;;
esac

if [[ -z "$out" ]]; then
	out="${width}x${height}.${inputn}"
fi

if [[ -f "$out" ]]; then
	echo "$out - already exists. overwrite?"
	read confirmation
	[[ "${confirmation,,}" != y* ]] && exit 1
fi

convert "$input" -background "$color" -gravity center -extent ${width}x${height} "$out"
echo "created $out"
