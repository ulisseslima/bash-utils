#!/bin/bash -e
# pull changes from another project without leaving the working directory
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

target="$1"
require target "arg 1: project dir"

pushd .
cd $target
git pull
popd
