#!/bin/bash

HOST=$1
shift
PORT_START=1
PORT_END=9999
UPDATE_STATUS=1000

while test $# -gt 0
do
    case "$1" in
        --status|-s) shift
        	UPDATE_STATUS=$1
        	echo "status turned on for each $1 th port"
            ;;
        --range|-r) shift
        	PORT_START=$1
        	shift
        	PORT_END=$1
        	echo "finding open ports from $PORT_START to $PORT_END"
        	break
            ;;
        --*) 
        	echo "bad option $1"
        	exit 1
            ;;
        *) echo "usage: $0 host.address {port_start {port_end}} {--status|-s}"
            ;;
    esac
    shift
done

check_status() {
	if [ $UPDATE_STATUS != 0 ]; then
		if [ $(( port % UPDATE_STATUS )) == 0 ]; then
			echo "$port"
		fi
	fi
}

test_port() {
	nc -z $HOST $port 1>/dev/null 2>&1; result=$?;
	if [ $result -eq 0 ]; then
    	echo "$port is listening"
	fi
}

for (( port=$PORT_START; port<=$PORT_END; port++ ))
do
	check_status
	test_port
done

exit 0
