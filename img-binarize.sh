#!/bin/bash
# keeps only black and white for the image
# https://www.rapidtables.com/web/tools/pixel-ruler.html
# https://groups.google.com/g/tesseract-ocr/c/Wdh_JJwnw94/m/24JHDYQbBQAJ?pli=1
# https://tesseract-ocr.github.io/tessdoc/ImproveQuality.html

source $(real require.sh)


input="$1"
require -f input

# 60
threshold=$2

out="$(dirname $input)/${threshold}_bin.$(basename $input)"
if [[ -n "$threshold" ]]; then
    convert "$input" -threshold $threshold% "$out"
else
    otsuthresh "$input" "$out" >/dev/null
fi
echo "$out"
