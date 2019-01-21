#!/bin/bash

# compiles and runs a (packageless) java class in a simple way
# requires java and javac

classp=.
if [[ "$1" == '-cp' ]]; then
	shift
	classp="$1"
	shift
fi

j="$1"
if [ ! -f "$j" ]; then
	echo "first argument must be a Class.java, '$j' is not a file"
	exit 1
fi

jdir=$(dirname "$j")
jclass=$(basename "$j" | cut -d'.' -f1)

# pass only the rest of the arguments to the java program
shift

jsrc=$jclass.java
jbin=$jclass.class

# so the bin is always up to date
rm -f /tmp/$jbin

pushd .
cd "$jdir"
javac $jsrc
mv $jbin /tmp/$jbin

cd /tmp
java -cp $classp $jclass "$@"

popd
