#!/bin/bash -e
# math ops using local postgres

source $(real require.sh)

op="$1"
if [[ -n "$op" ]]; then
	shift
else
	>&2 echo "enter math expression:"
	read op
fi

require op 'math expression'
require PSQL "psql connection string"

psql="$PSQL"

while test $# -gt 0
do
    case "$1" in
    --connection|-c)
	shift
	psql="$1"
    ;;
    --round|-r)
	round=2

	if [[ -n "$2" && "$2" != -* ]]; then
	  shift
	  round="$1"
	fi
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

if [[ -n "$round" ]]; then
	$psql -qAtX -c "select round($op, $round)"
else
	$psql -qAtX -c "select $op"
fi
