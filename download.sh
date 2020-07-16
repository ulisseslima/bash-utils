#!/bin/bash -e

url="$1"
f="${2-/tmp/file}"

echo "downloading $url ..."
curl --progress-bar "$url" -JLo $f

echo "downloaded to $f"
file $f