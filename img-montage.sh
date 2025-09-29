#!/bin/bash
# merge images in a tile
# https://stackoverflow.com/questions/20737061/merge-images-side-by-side-horizontally
# ex: montage [0-4].png -tile 5x1 -geometry +0+0 out.png

source $(real require.sh)

pattern="$1"
require pattern "file pattern to merge, accepts regex"

tile=${2}
require tile "tile pattern"

out=${3:-out.png}

#echo montage "$pattern" -tile $tile -geometry +0+0 $out
montage $pattern -tile $tile -geometry +0+0 $out

file $(readlink -f "$out")
#readlink -f "$out"
