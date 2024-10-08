#!/bin/bash
# https://stackoverflow.com/questions/7334754/correct-way-to-check-java-version-from-bash-script/56243046#56243046

source $(real require.sh)
J8=52

if [[ -d "$1" ]]; then
	export JAVA_HOME="$1"
elif [[ $(nan.sh "$1") == false ]]; then
	#javad="JAVA${1}_HOME"
	#export JAVA_HOME="${!javad}"
	class_fversion=$1
	java6=50
	java50=6
	difference="$(echo $(($class_fversion-$java6)) | tr -d '-')"
	echo "$((java50+difference))"
fi

require -d JAVA_HOME

"$JAVA_HOME/bin/java" -version 2>&1 | head -1 | cut -d'"' -f2 | sed '0,/^1\./s///' | cut -d'.' -f1
