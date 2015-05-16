#!/bin/bash -e

for i in `seq 1 254`;
do
	echo "trying $i"
	nohup ping -c 1 -W 5 -w 5 192.168.0.$i | grep 'bytes from' &
done

echo "done"
