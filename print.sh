#!/bin/bash -e

if [ ! -n "$1" ]; then
	echo "creates an image from a text. first argument must be the text to print"
	exit 0
fi

text="$1"
convert -size 320x240 xc:grey30 -pointsize 79 -gravity center -draw "fill grey70  text 0,0'$text'" "$text.png"

echo "created $(readlink -f $text.png)"
