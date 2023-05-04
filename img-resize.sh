#!/bin/bash
# changes the input image to the desired width, then crops the height to fit

input="$1"
inputn=$(basename "$input")

width="$2"
height="$3"

redim="redim.${inputn}"
convert -resize ${width}x "$input" "$redim"
convert "$redim" -gravity center -crop x${height}+0+0 "${width}x${height}.${inputn}"
