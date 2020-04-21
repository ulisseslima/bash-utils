#!/bin/bash -e
# move files that are not java out of src

if [ ! -n "$1" ]; then
	echo "arg 1 must be the file pattern"
	exit 1
fi

if [ ! -d "$2" ]; then
	echo "arg $2 must be an existing source folder: '$src'"
	exit 1
fi

if [ ! -d "$3" ]; then
	echo "arg $3 must be an existing destination folder: '$des'"
	exit 1
fi

pattern="${1}"
src=$(readlink -f "$2")
des=$(readlink -f "$3")

echo "confirm directories and press enter to continue or CTRLC+C to abort:"
echo "sources: $src"
echo "destination: $des"
echo "pattern: $pattern"
read key

echo "moving sources..."
for f in $(find $src -name "$pattern")
do
	file=$(readlink -f $f)
	if [ -d "$file" ]; then
		continue
	fi

	if [[ "$file" == *CVS* ]]; then
		continue
	fi

	fname=$(basename $file)
	fdir=$(dirname $file)
	desdir=${fdir/$src/$des}

	mkdir -p $desdir
	echo "mv $file $desdir"
	mv $file $desdir
done