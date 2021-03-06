#!/bin/bash

if [ "$1" == '--help' ]; then
	echo "usage:"
	echo "$0 host.name"
	echo "or, to set an interval (in seconds) different to the default of 60 seconds:"
	echo "$0 host.name 10"
	exit 0
fi

if [[ ! -n "$1" ]]; then
	echo "first arg must be host list (separed by space)"
	exit 1
fi

hosto="$1"

sleepo=60
if [[ -n $2 ]]; then
	sleepo=$2
fi

function test_hosts() {
	dato=`date`
	echo ""
	echo "$dato"
	echo "############################"

	for host in "$@"
	do
		pingo=`ping -c 1 $host`
		if [[ $pingo == *'100% packet loss'* ]]; then
			echo "$host: ..."
		else
			latency=$(echo "$pingo" | grep time= | rev | cut -d'=' -f1 | rev)
			echo "$host: OK ($latency)"
		fi
	done
}

echo "Will ping $hosto every $sleepo seconds..."
while true
do
	test_hosts $hosto
	sleep $sleepo
done
