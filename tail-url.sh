#!/bin/bash -e
# pull changes from another project without leaving the working directory
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

# TODO https://stackoverflow.com/questions/31293629/is-there-a-way-to-perform-a-tail-f-from-an-url