#!/bin/bash
set -euo pipefail

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

# Convert a 16:9 image to 9:16 by cropping the center portion.
# Input: 16x9_${name}_${sequence}.png (or similar 16:9 image)
# Output: 9x16_${name}-${sequence}.png

# load require helper (repository uses this pattern)
# shellcheck source=/dev/null
source $(real require.sh)

img="${1:-}"

require img "input image in 16:9 aspect ratio"

if [[ ! -e "$img" ]]; then
  echo "error: file does not exist: '$img'" >&2
  exit 1
fi

b=$(basename -- "$img")
dir=$(dirname -- "$img")

# Try to match 16x9_${name}-${sequence} pattern (name can contain dashes)
regex='^16x9_(.+)-([0-9]+)(\.[^.]+)?$'

if [[ "$b" =~ $regex ]]; then
  name="${BASH_REMATCH[1]}"
  seq="${BASH_REMATCH[2]}"
  ext="${BASH_REMATCH[3]}"
  out="${dir}/9x16_${name}-${seq}.png"
else
  # If pattern doesn't match, use original name with _portrait suffix
  name="${b%.*}"
  ext="${b##*.}"
  out="${dir}/${name}_portrait.png"
fi

# Get image dimensions
dimensions=$(identify -format "%wx%h" "$img")
width=$(echo "$dimensions" | cut -d'x' -f1)
height=$(echo "$dimensions" | cut -d'x' -f2)

# Calculate crop dimensions for 9:16 aspect ratio from center
# For 9:16, height should be 16/9 times the width
# crop_width = min(width, height * 9/16)
# crop_height = crop_width * 16/9

# Calculate the target crop width (based on height)
crop_width=$(awk "BEGIN {printf \"%.0f\", $height * 9 / 16}")

# If calculated crop width exceeds image width, recalculate based on width
if (( crop_width > width )); then
  crop_width=$width
  crop_height=$(awk "BEGIN {printf \"%.0f\", $width * 16 / 9}")
else
  crop_height=$height
fi

# Calculate offset to center the crop
x_offset=$(awk "BEGIN {printf \"%.0f\", ($width - $crop_width) / 2}")
y_offset=$(awk "BEGIN {printf \"%.0f\", ($height - $crop_height) / 2}")

>&2 echo "info: cropping ${crop_width}x${crop_height}+${x_offset}+${y_offset} from ${width}x${height}"

# Crop the center portion using ImageMagick
convert "$img" -crop "${crop_width}x${crop_height}+${x_offset}+${y_offset}" +repage "$out"

# Print absolute path of result
fout=$(readlink -f "$out")
>&2 echo "Created: $fout"
file "$fout"
open.sh "$fout"

exit 0
