#!/bin/bash
mydir=$(dirname `readlink -f $0`)

cp "$mydir/Combine.java" /tmp/
cd /tmp

combinations=2
if [[ "$1" == --combinations ]]; then
	shift
	combinations=$1
	shift
fi

if [ ! -f /tmp/Combinations.class ]; then
	echo compiling...
	javac Combine.java
fi

java -Dcombinations=$combinations Combine "$@"

cd "$mydir"
