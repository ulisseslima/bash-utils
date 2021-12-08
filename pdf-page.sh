#!/bin/bash

source="$1"
page="$2"
destination="${3:-$source.$page.jpg}"

convert -density 144 $source[$page] -resize 150% "$destination"
echo "$destination"
