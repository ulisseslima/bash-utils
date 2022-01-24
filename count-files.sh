#!/bin/bash
# recursively count files in a dir

dir="${1:-.}"
find "$dir" -type f -name '*' -printf x | wc -c
