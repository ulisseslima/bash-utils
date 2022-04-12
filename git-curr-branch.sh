#!/bin/bash

dir="$1"
if [[ -d "$dir" ]]; then
    pushd .
    cd "$dir"
fi

git rev-parse --abbrev-ref HEAD

if [[ -d "$dir" ]]; then
    popd
fi