#!/bin/bash
source /etc/profile

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

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
	--quiet|-q)
		quiet=true
	;;
	--out|-o)
		shift
		out="$1"
	;;
	-*)
		echo "bad option '$1'"
	exit 1
	;;
    esac
    shift
done

if [[ -z "$command" ]]; then
	echo "enter command:"
	read command
fi

if [[ -n "$out" ]]; then
	mkdir -p $(dirname "$out")
	cat /dev/null > "$out"
fi

while true
do
	if [[ "$quiet" != true ]]; then
		echo "$(date) - $i"
		echo "$command"
		eval $command
	fi

	((i+=1))
	if [[ -n "$out" ]]; then
		eval $command >> $out
	fi
	sleep $interval
done
