#!/bin/bash

f=$1
tag=$2

cat $f | sed -n "s:.*<$tag>\(.*\)</$tag>.*:\1:p"
