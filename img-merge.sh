#!/bin/bash
set -euo pipefail

# Merge two 9x16 images named like:
#   9x16_${name}-${sequence}
# into a single PNG named:
#   16x9_${name}_001.png
# Uses the repository helper `img-montage.sh`.

# load require helper (repository uses this pattern)
# shellcheck source=/dev/null
source $(real require.sh)

img1="${1:-}"
img2="${2:-}"

require img1 "first 9x16 image (e.g. 9x16_name-001.png)"

b1=$(basename -- "$img1")
b1=$(basename -- "$img1")
dir1=$(dirname -- "$img1")

# If second image wasn't provided, try to find the next sequence in the same directory.
if [[ -z "$img2" ]]; then
  # we'll compute img2 based on img1
  dir1=$(dirname -- "$img1")
fi

# capture name (greedy) and sequence (last -number), allow any extension
regex='^9x16_(.+)-([0-9]+)(\.[^.]+)?$'

if [[ "$b1" =~ $regex ]]; then
  name1="${BASH_REMATCH[1]}"
  seq1="${BASH_REMATCH[2]}"
else
  echo "error: first file name does not match pattern 9x16_${name}-${sequence}" >&2
  exit 2
fi

if [[ -n "$img2" ]]; then
  b2=$(basename -- "$img2")
  if [[ "$b2" =~ $regex ]]; then
    name2="${BASH_REMATCH[1]}"
    seq2="${BASH_REMATCH[2]}"
  else
    echo "error: second file name does not match pattern 9x16_${name}-${sequence}" >&2
    exit 2
  fi
else
  # compute next sequence filename using the same extension as img1
  if [[ "$b1" =~ $regex ]]; then
    ext1="${BASH_REMATCH[3]}"
  else
    # this should not happen (we validated b1 earlier), but guard anyway
    echo "error: cannot determine extension for automatic second file" >&2
    exit 4
  fi

  # numeric increment with support for leading zeros
  len=${#seq1}
  # avoid octal by forcing base 10
  next=$((10#$seq1 + 1))
  seq2=$(printf "%0${len}d" "$next")

  b2="9x16_${name1}-${seq2}${ext1}"
  img2="${dir1}/${b2}"
  >&2 echo "info: second image not provided, using next sequence file: '$img2'"

  # set name2 to the same name as name1 for later validation
  name2="$name1"

  if [[ ! -e "$img2" ]]; then
    echo "error: could not find next sequence file: '$img2'" >&2
    exit 5
  fi
fi

if [[ "$name1" != "$name2" ]]; then
  echo "error: the two files do not share the same name part: '$name1' vs '$name2'" >&2
  exit 3
fi

out="${dir1}/16x9_${name1}_001.png"

tmp=$(mktemp --suffix=.png)
trap 'rm -f "$tmp"' EXIT

# Use the helper script to montage side-by-side (2x1)
# We pass the two filenames as a single argument (space separated). The helper expands it for montage.
# Note: filenames containing spaces may break the helper's simple splitting behavior.
"$(dirname -- "$0")/img-montage.sh" "$img1 $img2" 2x1 "$tmp"

# Ensure final output is PNG (helper wrote PNG because tmp has .png suffix). Move into place.
mv -f "$tmp" "$out"

# Print absolute path of result (consistent with img-montage.sh behavior)
file "$(readlink -f "$out")"

exit 0
