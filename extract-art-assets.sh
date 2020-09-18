#!/bin/bash
# extract art assets from a unity project
project="$(readlink -f $1)"
if [[ ! -d "$project" ]]; then
    echo "arg 1 must be a project directory"
fi

pname=$(basename $project)
fname=${pname}_assets-art.tar.gz

find $project -name "*.fbx*" -o -name "*.mat*" -o -name "*.png*" -o -name "*.tif*" | tar -cf $fname -T -
readlink -f $fname
