#!/bin/bash
# https://stackoverflow.com/questions/2062020/how-can-i-tell-if-im-running-in-64-bit-jvm-or-32-bit-jvm-from-within-a-program
source $(real require.sh)

if [[ -n "$1" ]]; then
	JAVA_HOME="$1"
fi

require -d JAVA_HOME

# if error, jre is 32-bit
"$JAVA_HOME/bin/java" -d64 -version
