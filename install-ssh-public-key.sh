#!/bin/bash
# check:
# 	locally:
#	- ssh -vvv ... to debug
#	on server:
#	- /var/log/auth.log
#	- 0700 permissions for the ENTIRE user's home, 0644 permissions for authorized_keys. ls -lad $HOME to make sure
##

if [ ! -f ~/.ssh/id_rsa.pub ]; then
	echo "generating public ssh key..."
	ssh-keygen
fi

user_host=$1

if [ ! -n "$1" ]; then
	echo "first argument must be user@host"
	exit 1
fi

port=22
if [ -n "$2" ]; then
	port=$2
fi

echo "installing key for -p $port $user_host"

pub_key=$(readlink -f ~/.ssh/id_rsa.pub)
cat $pub_key

echo "ssh-copy-id -p $port -i $pub_key $user_host"
ssh-copy-id -p $port -i $pub_key $user_host
