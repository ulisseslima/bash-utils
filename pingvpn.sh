#!/bin/bash

hosto=cvs.murah
if [[ -n $1 ]]; then
        hosto=$1
fi

sleepo=60
if [[ -n $2 ]]; then
	sleepo=$2
fi

echo "Will ping $hosto every $sleepo seconds..."
while true
do
	dato=`date`
	pingo=`ping -c 1 $hosto`
	if [[ $pingo == *'100% packet loss'* ]]; then
		echo "$dato ..."
	else
		echo "$dato OK"
	fi
	sleep $sleepo
done

