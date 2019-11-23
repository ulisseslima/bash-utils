#!/bin/bash
source /etc/profile

ME=$(basename $MYSELF)
MYSELF="$(readlink -f "$0")"
I="${MYSELF%/*}"

do_help() {
	echo "usage:"
	echo "$0"
}

interval=1
max=1000
command=
i=1

while test $# -gt 0
do
    case "$1" in
	--help|-h)
        	do_help
        	exit 0
      	;;
      	--verbose|-v)
        	verbose=true
      	;;
      	--interval|-i)
      		shift
      		interval="$1"
      	;;
      	--command|-c)
      		shift
      		command="$1"
      	;;
	--max|-m)
		shift
		max="$1"
	;;
      	--*)
        	echo "bad option '$1'"
		exit 1
      	;;
    esac
    shift
done

while true
do
	echo "$(date) - $i"
	echo "$command"
	eval $command
	((i+=1))
	sleep $interval
done
