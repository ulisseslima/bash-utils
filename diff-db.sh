#!/bin/bash -e

# reads from std in or first arg. the catch is that it hangs if none are provided
stdin="${1:-`cat /proc/${$}/fd/0`}"
stdin2="$2"

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
verbose=false

require() {
	switch='-s'
	if [[ "$1" == *'-'* ]]; then
		switch=$1
		shift
	fi

	case $switch in
	  --string|-s)
		if [ ! -n "$1" ]; then
			echo "$2"
			exit 1
		fi
	  ;;
	  --file|-f)
		if [ ! -f "$1" ]; then
			echo "Arquivo não encontrado: '$1'"
			exit 1
		fi
	  ;;
	  --dir|-d)
		if [ ! -f "$1" ]; then
            echo "Diretório não encontrado: '$1'"
			exit 1
        fi
	  ;;
	esac
}

do_help() {
	echo "Template de script."
}

debug() {
	if [ $verbose == "true" ]; then
		echo "$1"
	fi
}

while test $# -gt 0
do
    case "$1" in
        --verbose|-v|--debug) 
        	verbose=true
        ;;
        --help|-h)
        	do_help
        	exit 0
        ;;
        --*) echo "opção não reconhecida: '$1'"
        	exit 1
	    ;;
    esac
    shift
done

extract_tables() {
in_function=false
in_table=false
while read line
do
	if [[ "$line" == 'CREATE FUNCTION'* ]]; then
		in_function=true
	fi

	if [[ $in_function == true ]]; then
		if [[ "$line" == '$$;'* ]]; then
			in_function=false
		fi
	else
		if [[ "$line" == 'CREATE TABLE'* ]]; then
			in_table=true
		fi
	fi

	if [[ $in_table == true ]]; then
		echo "$line"
		if [[ "$line" == ');' ]]; then
			in_table=false
		fi
	fi
done < $1
}

fout1="tables-1.sql"
fout2="tables-2.sql"

extract_tables $stdin > "$fout1"
extract_tables $stdin2 > "$fout2"

diff "$fout1" "$fout2"
