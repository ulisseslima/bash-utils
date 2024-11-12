#!/bin/bash -e
# concatenates a collection of videos
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

trap 'catch $? $LINENO' ERR
catch() {
  if [[ "$1" != "0" ]]; then
    error="$ME - returned $1 at line $2"
    >&2 echo "$error"
    notify-send "$error"
  fi
}

source $(real require.sh)

sources=$(cat /dev/stdin)
out=mixed.mp4

while test $# -gt 0
do
    case "$1" in
    --out|-o)
      shift
      out="$1"
    ;;
    -*)
      err "bad option '$1'"
      exit 1
    ;;
    esac
    shift
done

echo "concatenating sources:
$sources"

ffmpeg <&1- -y -v 16 -safe 0 -f concat -i <(echo "$sources") -c copy "$out"
