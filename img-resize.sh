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

# 16/9=1.77~
ratio=1.7777777777777778
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
      #height=$(op.sh "${height}*$ratio" | cut -d'.' -f1)
    ;;
    --height|-h)
      shift
      height="$1"
      #width=$(op.sh "${height}*$ratio" | cut -d'.' -f1)
    ;;
    --portrait)
      orientation=portrait
    ;;
    --landscape)
      orientation=landscape
    ;;
    --orientation)
      shift
      orientation="$1"
    ;;
    --from)
      shift
      from=$1
      [[ "$from" == top ]] && from=north
      [[ "$from" == bottom ]] && from=south
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
  >&2 echo "orientation detected: $orientation"
fi

if [[ $orientation == landscape ]]; then
  redim="${image_dir}/redim${width}p.${img_base}.png"
  convert -resize ${width}x "$input" "$redim"

  redim_res=$(identify "$redim" | cut -d' ' -f3)
  redim_h=$(echo "$redim_res" | cut -d'x' -f2)

  if [[ "$redim_h" -lt $height ]]; then
    cropped="${image_dir}/cropped${width}p.${img_base}.png"
    convert "${redim}" -gravity $from -background black -extent x$height "${cropped}"
  else
    cropped="${image_dir}/cropped${width}p.${img_base}.png"
    convert "${redim}" -gravity $from -crop x${height}+0+0 "${cropped}"
  fi

  rm "$redim"
else
  redim="${image_dir}/redim${width}p.${img_base}.png"
  convert -resize x${width} "$input" "$redim"

  redim_res=$(identify "$redim" | cut -d' ' -f3)
  redim_w=$(echo "$redim_res" | cut -d'x' -f1)

  if [[ "$redim_w" -ge $width ]]; then
    cropped="${image_dir}/cropped${width}p.${img_base}.png"
    convert "${redim}" -gravity $from -background black -extent ${height}x "${cropped}"
  else
    cropped="${image_dir}/cropped${width}p.${img_base}.png"
    convert "${redim}" -gravity $from -crop ${height}x+0+0 "${cropped}"
  fi

  rm "$redim"
fi

if [[ -z "$out" ]]; then
  cp "$input" /tmp
  mv "${cropped/\%03d/001}" "${image_dir}/${img_base}.png"
  >&2 echo "image replaced"
  echo "${image_dir}/${img_base}.png"
else
  mv "${cropped/\%03d/001}" "$out"
  echo "$out"
fi
