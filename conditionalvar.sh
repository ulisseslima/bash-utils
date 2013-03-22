#!/bin/bash

nargs=$#

if [ $nargs == 0 ]; then
  echo "no args were provided"
else
  echo "$nargs provided"
fi

conditional=${1:-"hehe"}

echo "Conditional: $conditional"
