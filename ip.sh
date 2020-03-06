#!/bin/bash

if [ ! -n "$1" ]; then
	echo "resolves the IP of the hostnamed passed using Google's DNS (8.8.4.4)"
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

host=$1
dns=${2:-8.8.4.4}

ip=$(dig @$DNS_CAIXA $host | awk '/ANSWER/{getline; print}' | rev | awk '{split($0,a,"\t"); print a[1]}' | rev | grep -v '^$')
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

