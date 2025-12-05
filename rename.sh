#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

show_help() {
  cat <<EOF
Usage: rename.sh [OPTIONS] START_DIR

Recursively rename files under START_DIR using options:
  --prefix PREFIX     Add PREFIX before the filename (keeps extension)
  --suffix SUFFIX     Add SUFFIX after the filename (before extension)
  --pattern PATTERN   Filename pattern to match (default: "*")
  -h, --help          Show this help

Examples:
  rename.sh --prefix new_ --pattern "*.mp4" ./videos
  rename.sh --suffix _v2 --pattern "*.jpg" /path/to/dir

Notes:
- The script will avoid overwriting existing files by appending _1, _2, ...
- Pattern is used with `find -name`, so use quotes for globs (e.g. "*.mp4").
EOF
}

# defaults
prefix=""
suffix=""
pattern="*"
start_dir="."

# parse args
start_dir_given=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      prefix="$2"; shift 2;;
    --prefix=*)
      prefix="${1#*=}"; shift;;
    --suffix)
      suffix="$2"; shift 2;;
    --suffix=*)
      suffix="${1#*=}"; shift;;
    --pattern)
      pattern="$2"; shift 2;;
    --pattern=*)
      pattern="${1#*=}"; shift;;
    -h|--help)
      show_help; exit 0;;
    --)
      shift; break;;
    *)
      if [[ $start_dir_given -eq 0 ]]; then
        start_dir="$1"
        start_dir_given=1
        shift
      else
        echo "Unknown argument: $1" >&2
        show_help
        exit 1
      fi
      ;;
  esac
done

# Validate start_dir
if [[ -z "$start_dir" ]]; then
  start_dir='.'
fi
if [[ ! -d "$start_dir" ]]; then
  echo "Start directory does not exist: $start_dir" >&2
  exit 1
fi

# Find and rename
# Use find with -print0 to safely handle spaces/newlines
find "$start_dir" -type f -name "$pattern" -print0 | while IFS= read -r -d '' file; do
  dir=$(dirname -- "$file")
  base=$(basename -- "$file")

  # Split name and extension. Treat leading-dot files without another dot as no-ext
  if [[ "$base" = .* && "$base" != *.* ]]; then
    name="$base"
    ext=""
  else
    name="${base%.*}"
    ext="${base##*.}"
    if [[ "$name" == "$ext" ]]; then
      # no extension
      ext=""
      name="$base"
    fi
  fi

  newbase="${prefix}${name}${suffix}"
  if [[ -n "$ext" ]]; then
    newbase+=".$ext"
  fi

  newpath="$dir/$newbase"

  # If identical, skip
  if [[ "$newpath" == "$file" ]]; then
    continue
  fi

  # Avoid overwrite: append _N if needed
  candidate="$newpath"
  i=1
  while [[ -e "$candidate" ]]; do
    candidate="$dir/${prefix}${name}${suffix}_$i"
    if [[ -n "$ext" ]]; then
      candidate+=".$ext"
    fi
    ((i++))
  done

  # Perform rename
  mv -v -- "$file" "$candidate"
done
