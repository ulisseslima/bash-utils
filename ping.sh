#!/bin/bash

if [ "$1" == '--help' ]; then
	echo "usage:"
	echo "$0 host.name"
	echo "or, to set an interval (in seconds) different to the default of 60 seconds:"
	echo "$0 host.name 10"
	exit 0
fi

hosts='cvs.murah smb.murah'
if [[ -n $1 ]]; then
        hosto=$1
fi

sleepo=60
if [[ -n $2 ]]; then
	sleepo=$2
fi

function test_hosts() {
	for host in "$@"
	do
		dato=`date`
		pingo=`ping -c 1 $host`
		if [[ $pingo == *'100% packet loss'* ]]; then
			echo "$dato - $host: ..."
		else
			echo "$dato - $host: OK"
		fi
	done
}

echo "Will ping $hosto every $sleepo seconds..."
while true
do
	test_hosts $hosts
	sleep $sleepo
done
