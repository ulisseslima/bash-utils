#!/bin/bash

source $(real require.sh)

branch="$1"
require branch 'branch to override from'

c="git reset --hard origin/$branch"
echo $c
$c
