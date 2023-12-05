#!/bin/bash

java=$1
if [[ ! -d "$java" ]]; then
	echo "not a dir: $java"
	exit 1
fi

if [[ ! -f "$java/jre/bin/java" ]]; then
	echo "diretório deve ser o root do java: $java"
	exit 1
fi

cd "$java/jre/lib/ext"
rm -f java-atk-wrapper.jar
if [[ -f "/usr/share/java/java-atk-wrapper.jar" ]]; then
	echo "linking jar..."
	sudo ln -s /usr/share/java/java-atk-wrapper.jar "$java/jre/lib/ext"
fi

rm -f libatk-wrapper.so
if [[ -f "/usr/lib/x86_64-linux-gnu/jni/libatk-wrapper.so" ]]; then
	echo "linking lib..."
	sudo ln -s /usr/lib/x86_64-linux-gnu/jni/libatk-wrapper.so "$java/jre/lib/ext"
fi

ls -la "$java/jre/lib/ext"
