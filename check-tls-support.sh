#!/bin/bash -e
# check what versions of TLS a server supports
# nmap -sV --script ssl-enum-ciphers -p 443 <host>
source $(real require.sh)

mode=full

host=$1
require host

# no port specified, use default
if [[ "$host" != *":"* ]]; then
	port=443
else
	port=$(echo $host | cut -d':' -f2)
	host=$(echo $host | cut -d':' -f1)
fi

while test $# -gt 0
do
    case "$1" in
        --simple)
            mode=simple
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

case $mode in
	simple)
		extra="grep TLSv"
	;;
esac

command="nmap -sV --script ssl-enum-ciphers -p $port $host"

if [[ -n $extra ]]; then
	$command | $extra
else
	$command
fi
