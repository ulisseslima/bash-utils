#!/bin/bash

source $(real require.sh)

DIR="$1"

require -d DIR

find $DIR -type f -name '*' -exec git-newline-at-eof.sh {} \;
