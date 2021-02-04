#!/bin/bash -e
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

file="${1}"
require -f file

sed -i "s/====/##/g" "$file"
sed -i "s/==/#/g" "$file"
