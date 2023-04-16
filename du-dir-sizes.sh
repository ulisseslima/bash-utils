#!/bin/bash

source $(real require.sh)

dir="$1"
require dir 'dir to check'

du -d 0 $dir/* | sort -n
