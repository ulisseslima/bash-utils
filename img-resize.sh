#!/bin/bash -e
# @installable
# resizes an image to 16:9 full HD, cropping or adding black bars when necessary
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

trap 'catch $? $LINENO' ERR
catch() {
  if [[ "$1" != "0" ]]; then
    >&2 echo "$ME - returned $1 at line $2"
  fi
}

source $(real require.sh)

input="$1"
shift

require -f input
input=$(readlink -f "$input")
image_dir=$(dirname "$input")
image_name=$(basename "$input")
img_base=$(echo "$image_name" | rev | cut -d'.' -f2- | rev)
image_ext=$(echo "$image_name" | rev | cut -d'.' -f1 | rev)

width=1920
height=1080

# NorthWest, North, NorthEast, West, Center, East, SouthWest, South, or SouthEast
from=center

while test $# -gt 0
do
    case "$1" in
    --out|-o)
      shift
      out="$1"
    ;;
    --width|-w)
      shift
      width="$1"
    ;;
    --height|-h)
      shift
      height="$1"
    ;;
    --portrait)
      orientation=portrait
    ;;
    --landscape)
      orientation=landscape
    ;;
    --from)
      shift
      from=$1
    ;;
    -*)
      err "bad option '$1'"
      exit 1
    ;;
    esac
    shift
done

original_res=$(identify "$input" | cut -d' ' -f3)
original_w=$(echo "$original_res" | cut -d'x' -f1)
original_h=$(echo "$original_res" | cut -d'x' -f2)

if [[ -z "$orientation" ]]; then
  if [[ $original_h -gt $original_w ]]; then
    orientation=portrait
  else
    orientation=landscape
  fi
fi

if [[ $orientation == landscape ]]; then
  redim="${image_dir}/redim${width}p.${img_base}.png"
  convert -resize ${width}x "$input" "$redim"

  cropped="${image_dir}/cropped${width}p.${img_base}.png"
  convert "${redim}" -gravity $from -crop x${height}+0+0 "${cropped}"
  rm "$redim"
else
  redim="${image_dir}/redim${width}p.${img_base}.png"
  convert -resize x${width} "$input" "$redim"
  
  cropped="${image_dir}/cropped${width}p.${img_base}.png"
  convert "${redim}" -gravity $from -crop ${height}x+0+0 "${cropped}"
  rm "$redim"
fi

if [[ -z "$out" ]]; then
  mv "${cropped/\%03d/001}" "${image_dir}/${img_base}.png"
  mv "$input" /tmp
else
  mv "${cropped/\%03d/001}" "$out"
fi
