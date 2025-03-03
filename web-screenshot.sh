#!/bin/bash
# takes a screenshot from a web page

source $(real require.sh)

url="$1"
require url "url to screenshot"

outd=$(dirname "$url")
out="$(safe-name.sh $(basename "$url")).png"

resolution=1920,1080

while test $# -gt 0
do
    case "$1" in
        --out|-o)
	    shift
	    out="$1"
        ;;
        --resolution)
	    shift
	    resolution="$1"
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

echo "google-chrome --headless --disable-gpu --screenshot='$out' '$url' --window-size=$resolution"
google-chrome --headless --disable-gpu --screenshot="$out" "$url" --window-size=$resolution
# other ops: --dump-dom
