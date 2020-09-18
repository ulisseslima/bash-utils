#!/bin/bash
# extract sfx assets from a unity project
project="$(readlink -f $1)"
if [[ ! -d "$project" ]]; then
    echo "arg 1 must be a project directory"
fi

pname=$(basename $project)
fname=${pname}_assets-sfx.tar.gz

find $project -name "*.wav" -o -name "*.ogg" | tar -cf $fname -T -
readlink -f $fname
