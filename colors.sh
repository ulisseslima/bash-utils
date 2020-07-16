#!/bin/bash
# reduce color number and depth

img="$1"
colors=${2:-16}
depth=${3:-4}

if [[ ! -f "$img" ]]; then
    echo "arg 1 must be a file"
    exit 1
fi

fname=$(basename -- "$img")
if [[ "$fname" != *.* ]]; then
    echo "file must have an extension"
    exit 1
fi
ext="${fname##*.}"
name="${fname%.*}"

if [[ -n "$4" ]]; then
    ext=${4//./}
fi

fr="${name}_${colors}-${depth}.${ext}"

echo "colors: $colors"
echo "depth: $depth"
echo "extension: $ext"

convert "$img" +dither -colors $colors -depth $depth ${fr} 
readlink -f "$fr"