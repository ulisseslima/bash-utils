#!/bin/bash
# https://stackoverflow.com/questions/7334942/is-there-something-like-a-css-selector-or-xpath-grep
# dependency: html-xml-utils

selector="$1"
in="${2:-/dev/stdin}"

cat "$in" | hxselect -s '\n' -c "$selector" | sed '/^\s*$/d'
