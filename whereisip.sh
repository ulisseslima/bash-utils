#!/bin/bash -e

ip="$1"

if [ ! -n "$ip" ]; then
	echo "primeiro argumento deve ser um hostname ou ip"
	exit 1
fi

re='^[0-9]'
if ! [[ $ip =~ $re ]] ; then
	ip=`resolveip -s "$1"`
fi

curl ipinfo.io/$ip
