#!/bin/bash -e

silent=${4:-false}

if [ ! -f "$3" ]; then
	echo "third argument must be a file"
fi

[[ $silent == false ]] && echo "replacing '$1' with '$2' in '$3'"
sed -i "s/$1/$2/g" "$3"
