#!/bin/bash

##
# remove the first line from the file and return it
function next() {
	file=$1
	sed -i -e '1 w /dev/stdout' -e '1d' $file
}

next "$1"
