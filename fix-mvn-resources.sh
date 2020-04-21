#!/bin/bash -e
# move files that are not java out of src

src=$(readlink -f "$1")
res=$(readlink -f "$2")
pattern="${3:-*.java}"

if [ ! -d "$src" ]; then
	echo "first arg must be an existing source folder: '$src'"
	exit 1
fi

if [ ! -d "$res" ]; then
	echo "second arg must be an existing resource folder: '$res'"
	exit 1
fi

echo "confirm directories and press any key to continue or CTRLC+C to abort:"
echo "sources: $src"
echo "resources: $res"
echo "pattern: !$pattern"
read key

echo "fixing sources..."
for f in $(find $src ! -name "$pattern")
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
	resdir=${fdir/$src/$res}

	mkdir -p $resdir
	echo "mv $file $resdir"
	mv $file $resdir
done

echo "fixing resources..."
for f in $(find $res -name "$pattern")
do
        file=$(readlink -f $f)
        if [ -d "$file" ]; then
                continue
        fi

        if [ "$file" == *CVS* ]; then
                continue
        fi

        fname=$(basename $file)
        fdir=$(dirname $file)
        srcdir=${fdir/$res/$src}

        mkdir -p $srcdir
        echo "mv $file $srcdir"
        mv $file $srcdir
done

