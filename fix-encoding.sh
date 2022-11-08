#!/bin/bash
# recursively converts a directory tree to utf-8

source $(real require.sh)

startd="$1"
require -d startd

for f in $(find $startd)
do
    file=$(readlink -f $f)
    if [ -d "$file" ]; then
        continue
    fi

    fname=$(basename $file)
    fdir=$(dirname $file)

    echo "$fname ..."
    convert.sh --to-utf-8 $file
done
