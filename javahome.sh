#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root" 1>&2
   exit 1
fi

javahome=$1
home_location=/etc/profile

if [ ! -n "$javahome" ]; then
	echo "java directory must be the first argument"
	exit 1
fi

if [ -n "$JAVA_HOME" ]; then
	echo "JAVA_HOME was already set as $JAVA_HOME"
fi

echo "removing any definitions of JAVA_HOME in $home_location"
sed -i "/JAVA_HOME/d" $home_location

echo "saving PATH from ${home_location}..."
syspath=$(tac $home_location | grep -m 1 PATH)
echo "$syspath"

sed -i "/PATH=/d" $home_location
echo "export JAVA_HOME=\"$javahome\"" >> $home_location
echo "PATH=\"$javahome/bin:$PATH\"" >> $home_location
echo "new PATH: `grep 'PATH=' $home_location`"
