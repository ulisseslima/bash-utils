#!/bin/bash

if [ ! -n "$1" ]; then
	echo "resolves the IP of the hostname passed using Google's DNS (8.8.4.4)"
	echo ""
	echo "first argument must be the host"
	exit 1
fi

update_hosts() {
  ip=$1
  host=$2

  grep -v "$host" /etc/hosts > /tmp/hosts.2
  echo "$ip $host" >> /tmp/hosts.2
  sudo mv /tmp/hosts.2 /etc/hosts

  echo "added to hosts: $ip $host"
}

if [ ! -n "$DEFAULT_DNS" ]; then
	DEFAULT_DNS=8.8.4.4
fi

host=$1
# TODO check if DEFAULT_DNS not null
dns=${2:-$DEFAULT_DNS}

ip=$(dig @$dns $host | awk '/ANSWER/{getline; print}' | rev | awk '{split($0,a,"\t"); print a[1]}' | rev | grep -v '^$')
echo "$host ($ip) [$dns]"

for arg in "$@"
do
      case "$arg" in
        --add|-a)
          update_hosts $ip $host
          exit 0
        ;;
        --verbose|-v)
          verbose=true
        ;;
        --*)
          echo "bad option '$1'"
	  exit 1
        ;;
    esac
done

