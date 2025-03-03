#!/bin/bash
# linear transform in percentage.
# e.g.:
# $0 485.37 --min 175 --max 781
# > 51.00 #(%)

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
        --min)
            shift
	    min="$1"
        ;;
        --max)
            shift
	    max="$1"
        ;;
        *)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done


# Calculate the percentage
percentage=$(echo "scale=2; (($value - $min) / ($max - $min)) * 100" | bc)

# Output the result
echo "${percentage}"

