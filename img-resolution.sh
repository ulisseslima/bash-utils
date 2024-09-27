#!/bin/bash
# image resolution in the format 'width height'

source $(real require.sh)

input="$1"
format='%w %h'

require -f input
shift

while test $# -gt 0
do
    case "$1" in
        --format)
	    shift
	    format="$1"
        ;;
        --width|-w)
            format="%w"
        ;;
        --height|-h)
            format="%h"
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

identify -format "$format" "$input" && echo
