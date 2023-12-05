#!/bin/bash
# pads a number $1 with $2 zeroes from the left
source $(real require.sh)

pads="${2:-2}"

if [[ $# == 0 || "$1" == '_'* ]]; then
  read -r n
  [[ -n "$1" ]] && pads="${1:1}"
else
  n="$1"
fi

require n "number to pad"

printf "%0${pads}d\n" $n
