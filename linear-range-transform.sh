#!/bin/bash
# linear range transform. translates a value from one range to another
# e.g.:
# $0 285.37 --from 175 781 --to 1 10
# > 2.62

source $(real require.sh)

if [[ -t 0 ]]; then
  value=$1
  shift
else
  value=$(cat /dev/stdin)
fi

require value 'arg1 or stdin'

while test $# -gt 0
do
    case "$1" in
        --from)
            shift
	    fmin="$1"
	    shift
	    fmax="$1"
        ;;
        --to)
            shift
	    tmin="$1"
            shift
	    tmax="$1"
        ;;
        *)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done


result=$(echo "scale=2; ((${value} - ${fmin}) / (${fmax} - ${fmin}) * (${tmax} - ${tmin}) + ${tmin})" | bc)
echo "${result}"
