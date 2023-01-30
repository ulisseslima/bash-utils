#!/bin/bash
# jdk source code
# https://stackoverflow.com/questions/410756/is-it-possible-to-browse-the-source-of-openjdk-online
#
# java <= 8:
#   https://hg.openjdk.java.net/jdk8/jdk8/jdk/file/tip/src/share/classes/java/util/List.java
# java 9, 10:
#   https://hg.openjdk.java.net/jdk9/jdk9/jdk/file/tip/src/java.base/share/classes/java/util/List.java
# latest:
#   https://hg.openjdk.java.net/jdk/jdk/file/tip/src/java.base/share/classes/java/util/List.java
#
# note: for classes that have OS-specific implementation, the path changes. ex: https://hg.openjdk.java.net/jdk6/jdk6/jdk/file/tip/src/windows/native/sun/awt/splashscreen/splashscreen_sys.c
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

class=$1
java_version=${2} # empty for latest

require class

if [[ $class != */* ]]; then
    class=${class//./\/}
fi

if [[ $class != *.java ]]; then
    class=${class}.java
fi

if [[ -n "$java_version" && $java_version -le 8 ]]; then
    google-chrome "https://hg.openjdk.java.net/jdk$java_version/jdk$java_version/jdk/file/tip/src/share/classes/$class"
else
    google-chrome "https://hg.openjdk.java.net/jdk$java_version/jdk$java_version/file/tip/src/java.base/share/classes/$class"
fi
