#!/bin/bash -e
# merges a project into another

source $(real require.sh)

src=$(readlink -f "$1")
des=$(readlink -f "$2")

require -d "$src"
require -d "$des"

info "will merge '$src' into '$des', proceed?"
read confirmation

cd $WORKING_DIR

info "files before merge: $(find $des | wc -l)"
info "moving files..."
for f in $(find $src)
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

    mime=$(file -i $file)
    if [[ "$fname" == *.java ]]; then
        info "merging source - $mime"
        desdir="${fdir/$src/${des}/src}"
        mkdir -p $desdir
    else
        info "merging resource - $mime"
        desdir="${fdir/$src/${des}/resources}"
        mkdir -p $desdir
    fi

    convert.sh --to-utf-8 $file $desdir/$fname
done

info "merged."