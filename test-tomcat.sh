#!/bin/sh

set -e

dir_tomcat=`pwd`

clean_dir() {
	echo "Removing contents from $dir_tomcat/$1"
	rm -r "$dir_tomcat"/$1/*
}

check_dir() {
	if ( is_tomcat_root_dir "$1" ); then
		dir_tomcat="$1"
	fi
}

do_break() {
	rm -r temp
}

do_fix() {
	mkdir "$dir_tomcat"/temp
}

do_clean() {
	clean_dir work
	clean_dir temp
}

# Check whether the script is being run from a Tomcat root dir
is_tomcat_root_dir() {
	local dir="$1"
	if [ -d "$dir"/bin -a -d "$dir"/webapps -a -d "$dir"/lib -a -d "$dir"/conf -a -f "$dir"/LICENSE -a -f "$dir"/NOTICE ]; then
		return 0
	else
		return 1
	fi
}

if ( is_tomcat_root_dir $dir_tomcat ); then
	echo "Running from $dir_tomcat"
else
	echo "Couldn't find Tomcat files in $dir_tomcat, make sure you're running from a Tomcat root dir and all the default files are in place."	
fi

check_dir "$2"

case "$1" in
  break)
	do_break
	;;
  unbreak|fix)
	do_fix
	;;
  clean)
	do_clean "$3"
	exit 0
	;;
  *)
  	echo "From a Tomcat root dir:"
	echo "Usage: $0 {break|fix|clean}"
	exit 3
	;;
esac
