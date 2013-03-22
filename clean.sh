#!/bin/bash

set -e

clean_tomcat() {
	dir=`pwd`
	if [[ -n "$1" ]]; then
		dir="$1"
	fi
	echo "using '$dir'"
	rm -rf "$dir"/temp/* "$dir"/work/*
}

clean_jboss() {
	dir=`pwd`
	if [[ -n "$1" ]]; then
		dir="$1"
	fi
	echo "using '$dir'"
	rm -rf "$dir"/tmp/* "$dir"/work/* "$dir"/data/*
}

while test $# -gt 0
do
    case "$1" in
        tomcat) clean_tomcat "$2"
            ;;
        jboss) clean_jboss "$2"
            ;;
        --*) echo "bad option $1"
            ;;
        *) echo "Usage: $0 {start|stop|restart|force-reload}"
            ;;
    esac
    shift
done

