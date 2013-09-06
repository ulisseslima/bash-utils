#!/bin/bash -e

verbose=false

debug() {
	if [ $verbose == "true" ]; then
		echo "$1"
	fi
}

do_help() {
	echo "Options: "
	echo "--verbose|-v to activate verbosity"
	echo ""
	echo "--trim file"
	echo "--trim-all 'filepattern'"
	echo "--rm-bg file"
	echo "--rm-gb-all 'filepattern'"
	echo "--resize 64x64 file #will keep aspect ratio"
	echo "--resize 64x64\! file #will ignore aspect ratio"
	echo "--resize 50% file"
}

# This will fill pixels similar in color to the pixel at x=0 and y=0. We use a fuzz setting of 1% to make colors similar to the background transparent.
#
# This method works best on uniform backgrounds and objects with clear boundaries that make it stand out from the background.
#
# Reference:
# http://www.imagemagick.org/Usage/morphology/#intro
do_remove_bg() {
	file="$1"
	debug "removing background for file $file"
	convert "$file" -fill none -fuzz 1% -draw 'matte 0,0 floodfill' -flop  -draw 'matte 0,0 floodfill' -flop "$file"
}

do_remove_bg_collection() {
	pattern=$1
	debug "using file pattern $pattern"

	for f in $pattern
	do
		do_remove_bg "$f"
	done
}

do_trim() {
	file="$1"
	debug "trimming file $file"
	convert -trim "$file" "$file"
}

do_trim_collection() {
	pattern=$1
	debug "using file pattern $pattern"

	for f in $pattern
	do
		do_trim "$f"
	done
}

do_resize() {
	option="$1"
	file="$2"
	debug "resizing file $file to $option"
	convert "$file" -resize $option "${option}-${file}"
}

do_resize_collection() {
	option="$1"
	pattern="$2"
	debug "resizing all files that match $pattern to $option"

	for f in $pattern
	do
		do_resize $option "$f"
	done
}

while test $# -gt 0
do
    case "$1" in
	--help|-h)
	    do_help
	    exit 0
	;;
	--verbose|-v)
		verbose=true
		debug "verbosity: on"
	;;
    --trim) shift
	    do_trim "$1"
    ;;
	--trim-all) shift
	    do_trim_collection "$1"
	;;
    --rm-bg) shift
	    do_remove_bg "$1"
    ;;
    --rm-bg-all) shift
	    do_remove_bg_collection "$1"
    ;;
    --resize)
	shift
	option="$1"
	shift
	file="$1"

	do_resize $option "$file"
    ;;
    --*) echo "bad option $1"
    ;;
    esac
    shift
done

exit 0
