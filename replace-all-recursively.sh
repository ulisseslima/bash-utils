#!/bin/bash -e

verbose=false
replace=
with=
pattern="*.*"
sed="sed -i"

while test $# -gt 0
do
    case "$1" in
      --replace|-r)
		shift
        replace=$1
      ;;
      --with|-w)
		shift
        with=$1
      ;;
      --verbose|-v) 
        verbose=true
      ;;
      --preview)
		sed="sed"
		echo "preview mode enabled"
	  ;;
	  --pattern)
		shift
		pattern=$1
	  ;;
      --*) 
      	echo "bad option '$1'"
      	exit 1
      ;;
    esac
    shift
done

if [ ! -n "$replace" ]; then
	echo "--replace arg must be the pattern to replace"
	exit 1
fi

if [ ! -n "$with" ]; then
	echo "--with arg must be the replace string"
	exit 1
fi

if [[ $verbose == true ]]; then
	echo "replacing all occurences of '$replace' with '$with' recursively from `pwd`"
	echo "find . -type f -iname '$pattern' -print0 | xargs -0 $sed -i \"s/$replace/$with/g\""
fi

find . -type f -iname "$pattern" -print0 | xargs -0 $sed "s/$replace/$with/g"
