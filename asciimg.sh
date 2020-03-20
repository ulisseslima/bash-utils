#!/bin/bash

help() {
	echo "usage:"
	echo "$0 /image/path [10]"
	echo "first argument must be a valid path do a file."
	echo "second argument is optional and defines the percentage of the scale of the image. Default is 10" 
	echo ""
	echo "this script requires Java 8+ and https://github.com/ulisseslima/cuber.git"
	exit 0
}

img="$1"
if [ ! -f "$img" ]; then
	echo "first arg must be a file: '$img1'"
	exit 1
fi

scale=${2:-10}

inline-java.sh "println(\$img(\"$img\").toAscii($scale));"
