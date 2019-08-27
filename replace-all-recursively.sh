#!/bin/bash -e

if [ ! -n "$1" ]; then
	echo "first arg must be the pattern to replace"
	exit 1
fi

echo "replacing all occurences of '$1' with '$2' recursively from `pwd`"
echo "find . -type f -print0 | xargs -0 sed -i \"s/$1/$2/g\""
find . -type f -print0 | xargs -0 sed -i "s/$1/$2/g"
