#!/bin/bash

source $(real require.sh)

a="$1"
require a "value that represents 100%"
shift

b="$1"
require b "value to check percentage of"
shift

percent=$(cross-multiply.sh $a 100 $b x)
echo "${percent}%"
