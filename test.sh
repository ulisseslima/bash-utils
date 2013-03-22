#!/bin/bash

do_start() {
	echo "start!"
}

do_stop() {
	echo "stop!"
}

while test $# -gt 0
do
    case "$1" in
        --start) do_start
            ;;
        --stop) do_stop
            ;;
        --*) echo "bad option $1"
            ;;
        *) echo "Usage: $0 {start|stop|restart|force-reload}"
            ;;
    esac
    shift
done

ssh ulisses@murah.com 'smbclient //192.168.0.6/teste/ 6des7@murah -W Murah -U ulisseslima'

