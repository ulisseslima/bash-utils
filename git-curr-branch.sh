#!/bin/bash

dir="$1"
if [[ -d "$dir" ]]; then
    pushd . > /dev/null 2>&1
    cd "$dir"
fi

git rev-parse --abbrev-ref HEAD

if [[ -d "$dir" ]]; then
    popd > /dev/null 2>&1
fi