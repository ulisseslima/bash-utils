#!/bin/bash

SSH_PORT=22
SSH_USER=
SSH_PASS=
# only try ips greater than this number:
PORT_GT=0
DEBUG=0

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
        --debug)
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
if [ $PORT_GT -gt 0 ]; then
	echo "Trying only ips greater than $PORT_GT"
fi

for ip in $active_ips
do		
	ip_n=`echo $ip | cut -d. -f4`
	debug "$ip ($ip_n)"
	if [[ $ip_n > $PORT_GT || ! -n $ip_n ]]; then
		debug "ip passed > $PORT_GT || NaN test"
		nc -z $ip $SSH_PORT 1>/dev/null 2>&1; result=$?;
		if [ $result -eq 0 ]; then
			echo "trying $ip..."
			success=`sshpass -p $SSH_PASS ssh $SSH_USER@$ip "echo OK"`
			if [ "$success" == "OK" ]; then
				echo "
				$ip OK
				"
			fi
		fi
	fi
done

