#!/bin/bash

name="$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 5 | head -n 1)"
width=280
height=250
type=png
b64=false

while test $# -gt 0
do
	case "$1" in
		--name|-n)
			shift
			name="$1"
		;;
		--type|-t)
			shift
			type=$1
		;;
		--b64|-b)
			b64=true
		;;
		--size)
			shift
			width=$1
			shift
			height=$1

			if [[ "$width" =~ '^[0-9]+$' ]] ; then
				echo "width must be an integer: $width"
				exit 1
			fi

			if [[ "$height" =~ '^[0-9]+$' ]] ; then
				echo "height must be an integer: $height"
				exit 1
			fi
		;;
		-*)
			echo "unrecognized option: $1"
			exit 1
		;;
		*)
			echo "example:"
			echo "$0 --size 320 240 --type jpg --b64"
			exit 1
		;;
	esac
	shift
done

rfile="${name}-${width}x${height}.$type"
head -c "$((3*width*height))" /dev/urandom | convert -depth 8 -size "${width}x${height}" RGB:- "$rfile"
if [[ $b64 == true ]]; then
	base64 "$rfile" > "${rfile}.b64"
fi
