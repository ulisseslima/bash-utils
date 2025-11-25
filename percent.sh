#!/bin/bash
# returns the percentage of a value
# e.g.: $0 100 10 # means 10% of 100, yields 10
# optionally, runs a math operation
# e.g.: $0 100 10 --op '+' # adds 10% to 100

source $(real require.sh)
in="$1"
require -n in

if [[ -t 0 ]]; then
  shift
  percent="$1"
  shift
else
  percent=$(cat /dev/stdin)
fi

require percent 'percent as arg2 or stdin'
percent=$(echo "$percent" | tr -d '%')

verbose=false
op=
round=false

while test $# -gt 0
do
    case "$1" in
    --verbose|-v|--debug)
        verbose=true
    ;;
    --op)
        shift
        op="$1"
    ;;
    --add)
        op="+"
    ;;
    --decrease)
        op="-"
    ;;
    --round)
        round=true
    ;;
    --trunc-decimal|--no-decimal)
        trunc=true
    ;;
    --round-trunc)
        round=true
        trunc=true
    ;;
    -*)
        echo "bad option '$1'"
        exit 1
    ;;
    esac
    shift
done

if [[ -z "$in" || -z "$percent" ]]; then
    echo "usage (30% of 600): "
    echo "$0 600 30"
    exit 1
fi

diff=$(cross-multiply.sh 100 $in $percent x)
if [[ -z "$op" ]]; then
    if [[ "$trunc" == true ]]; then
        echo $diff | cut -d'.' -f1
    else
        echo $diff
    fi
    exit 0
fi

if [[ $verbose == true ]]; then
	>&2 echo "# ${in}${op}${diff} (${op}${percent}%)"
fi

value=$(echo "scale=2; ${in}${op}${diff}" | bc)
if [[ $round == true ]]; then
    round.sh $value | cut -d'.' -f1
else
    echo $value
fi
