#!/bin/bash
# https://stackoverflow.com/questions/7334754/correct-way-to-check-java-version-from-bash-script/56243046#56243046

if [ -n "$1" ]; then
	JAVA_HOME="$1"
fi

"$JAVA_HOME/bin/java" -version 2>&1 | head -1 | cut -d'"' -f2 | sed '0,/^1\./s///' | cut -d'.' -f1
