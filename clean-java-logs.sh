#!/bin/bash

set -e

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

