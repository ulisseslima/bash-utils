#!/bin/bash

if [ ! -f ~/.ssh/id_rsa.pub ]; then
	echo "generating public ssh key..."
	ssh-keygen
fi

user_host=$1

if [ ! -n "$1" ]; then
	echo "first argument must be user@host"
	exit 1
fi

echo "installing key for $user_host"

ssh-copy-id -i ~/.ssh/id_rsa.pub $user_host
