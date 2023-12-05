#!/bin/bash
# returns the percentage of a value
# optionally, runs a math operation

in="$1"
shift
percent=$1
shift

op=
round=false

while test $# -gt 0
do
    case "$1" in
    --verbose|-v)
        verbose=true
    ;;
    --op)
        shift
        op="$1"
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

value=$(echo "scale=2; ${in}${op}${diff}" | bc)
if [[ $round == true ]]; then
    round.sh $value | cut -d'.' -f1
else
    echo $value
fi