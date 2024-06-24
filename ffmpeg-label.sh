#!/bin/bash -e
# @installable
# adds a label to the bottom and resizes an image
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

box_size=50
font_size=$((box_size/2))

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
    --text)
      shift
      text="$1"
    ;;
    -*)
      err "bad option '$1'"
      exit 1
    ;;
    esac
    shift
done

require text

original_res=$(identify "$input" | cut -d' ' -f3)
original_w=$(echo "$original_res" | cut -d'x' -f1)
original_h=$(echo "$original_res" | cut -d'x' -f2)

if [[ $original_h -gt $original_w ]]; then
  orientation=portrait
else
  orientation=landscape
fi

if [[ $orientation == landscape ]]; then
  redim="${image_dir}/redim${width}p.${img_base}.png"
  convert -resize ${width}x "$input" "$redim"

  cropped="${image_dir}/cropped${width}p.${img_base}.png"
  convert "${redim}" -gravity center -crop x${height}+0+0 "${cropped}"
  rm "$redim"
else
  redim="${image_dir}/redim${height}p.${img_base}.png"
  convert -resize x${height} "$input" "$redim"
  # convert "$redim" -gravity center -crop ${width}x+0+0 "$image_dir"
  cropped="${image_dir}/cropped${height}p.${img_base}.png"
  convert "${redim}" -gravity center -crop ${width}x+0+0 "${cropped}"
  rm "$redim"
fi

labeled="${image_dir}/${img_base}%03d.png"
ffmpeg -i "${cropped}" \
-vf "drawbox=x=0:y=ih-${box_size}:w=iw:h=${box_size}:color=white@0.5:t=fill, drawtext=text='$text':fontcolor=black:fontsize=${font_size}:x=(w-text_w)/2:y=h-${box_size}+((${box_size}-text_h)/2)" \
"${labeled}"

rm "$cropped"

if [[ -z "$out" ]]; then
  mv "${labeled/\%03d/001}" "$input"
else
  mv "${labeled/\%03d/001}" "$out"
fi
