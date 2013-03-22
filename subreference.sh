#!/bin/sh

nargs=$#

if [ $nargs == 0 ]; then
  echo "no args were provided"
else
  echo "$nargs provided"
fi