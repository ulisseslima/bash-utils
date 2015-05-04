#!/bin/bash -e

if [ ! -f "$3" ]; then
	echo "third argument must be a file"
fi

echo "replacing '$1' with '$2' in '$3'"
sed -i 's/$1/$2/g' "$3"
