#!/bin/bash
# returns the percentage diff between two values

source $(real require.sh)

a="$1"
require a "first value"
shift

b="$1"
require b "second value"
shift

if [[ $(op.sh "$b>$a") == t* ]]; then
	c=$b
	b=$a
	a=$c
fi

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
    -*)
        echo "bad option '$1'"
    ;;
    esac
    shift
done

if [[ "$a" == *.* || "$b" == *.* ]]; then
	a="${a}::numeric"
	b="${b}::numeric"
	val=$(op.sh "round(($a-$b)*100/$b, 2)")
else
	val=$(op.sh "($a-$b)*100/$b")
fi

echo "${val}%"

