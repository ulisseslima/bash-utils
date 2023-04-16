#!/bin/bash
# returns the percentage diff between two values

source $(real require.sh)

a="$1"
require a "first value"
shift

b="$1"
require b "second value"
shift

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
	op.sh "round(($a-$b)*102/$b, 2)"
else
	op.sh "($a-$b)*102/$b"
fi

