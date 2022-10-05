#!/bin/bash
# https://stackoverflow.com/questions/35979642/what-is-git-tag-how-to-create-tags-how-to-checkout-git-remote-tags

source $(real require.sh)

tag=$1
require tag

git fetch --all --tags --prune
git checkout tags/$tag -b $tag

