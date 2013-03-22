#!/bin/bash

do_start() {
	sshpass -p $USER_PROXY_PW scp $USER_PROXY@$PROXY_HOST:$USER_PROXY_HOME/$1 $2
}

do_ssh() {
	sshpass -p $USER_PROXY_PW ssh $USER_PROXY@$PROXY_HOST
}

while test $# -gt 0
do
    case "$1" in
        ssh) do_ssh
            ;;
        cp) do_scp
            ;;
        --*) echo "bad option $1"
            ;;
        *) echo "Usage: $0 {missing}"
            ;;
    esac
    shift
done

