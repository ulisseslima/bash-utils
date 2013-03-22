#!/bin/bash

do_start() {
	sshpass -p murah scp ulisses@murah.com:/home/ulisses/$1 $2
}

do_ssh() {
	sshpass -p murah ssh ulisses@murah.com
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

