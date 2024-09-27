#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

delay=100 #centiseconds

while test $# -gt 0
do
    case "$1" in
        --in|-i)
	    shift
            in="$1"
        ;;
        --out|-o)
            shift
	    out="$1"
        ;;
	--delay)
	    shift
	    delay="$1"
	;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

require in
require out

convert -delay $delay -loop 0 $in $out
