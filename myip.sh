#!/bin/bash

SSH_PORT=22
SSH_USER=
SSH_PASS=0
# only try ips greater than this number:
PORT_GT=0
DEBUG=0
interactive=false

debug() {
	if [ $DEBUG -gt 0 ]; then
		echo "$1"
	fi
}

while test $# -gt 0
do
    case "$1" in
    	--help)
    		echo "example: $0 -u user -p password --port 22"
    		exit 0
    	;;
		--password|-p) shift
			SSH_PASS=$1
        ;;
		--interactive|-i)
			interactive=true
		;;
        --debug|-v)
        	DEBUG=1
        	debug "debug is active"
        ;;
		--user|-u) shift
			SSH_USER=$1
        ;;
		--port) shift
			SSH_PORT=$1
        ;;
        --start|--gt|-g) shift
        	PORT_GT=$1
        ;;
		--*) echo "bad option $1"
			exit 1
        ;;
    esac
    shift
done

echo "mapping..."
active_ips=`nmap -sP 192.168.0.0/24 | grep 192 | cut -d' ' -f5`
echo "will try to find ip for user $SSH_USER with pass $SSH_PASS"

#if [ $PORT_GT -gt 0 ]; then
#	echo "Trying only ips greater than $PORT_GT"
#fi

for ip in $active_ips
do
	debug "$ip"

	nc -w 5 -z $ip $SSH_PORT 1>/dev/null 2>&1; result=$?;
	if [ "$result" -eq 0 ]; then
		debug "trying $ip..."
		
		if [ "$SSH_PASS" == 0 ]; then
			ssh $SSH_USER@$ip
		elif [ "$interactive" == false ]; then
			success=`sshpass -p $SSH_PASS ssh $SSH_USER@$ip "echo OK"`
			if [ "$success" == "OK" ]; then
				echo "-- !! OK $ip OK !! --"
			fi
        else
			success=`ssh $SSH_USER@$ip "echo OK"`
            if [ "$success" == "OK" ]; then
                echo "-- !! OK $ip OK !! --"
            fi
		fi
	fi
done

