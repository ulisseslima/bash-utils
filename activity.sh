#!/bin/bash

nargs=$#

if [ $nargs == 0 ]; then
  echo "no args were provided"
else
  echo "$nargs provided"
fi

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

eu=15
mateus=3

#http://cvs.murah:5050/controleAtividades/apontamentoUsuarioHoje.do?idRecurso=3

http://cvs.murah:5050/controleAtividades/login.jsp?j_username=mateus

lynx -cmd_log=/home/wonka/bin/tmp/cvs.murah:5050 http://cvs.murah:5050/controleAtividades/apontamentoUsuarioHoje.do?idRecurso=15

