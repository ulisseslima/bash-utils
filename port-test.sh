#!/bin/bash

ip=$1
port=$2

do_test() {
	ip=$1
	port=$2
	echo "Testing port $port on ip $ip"
	nc -z $ip $port 1>/dev/null 2>&1; result=$?;
	if [ $result -eq 0 ]; then
		echo "OK"
	else
		echo "FAIL"
	fi	
}

while test $# -gt 0
do
    case "$1" in
		--mysql) shift
		port=3306
        ;;
		--postgre|--postgresql) shift
		port=5432
        ;;
		--sqlserver) shift
		port=1433
        ;;
		--oracle) shift
		port=1521
        ;;
		--*) echo "bad option $1"
        ;;
    esac
    shift
done

do_test $ip $port
