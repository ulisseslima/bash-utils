#!/bin/bash -e
# date ops using local postgres

source $(real require.sh)

op="$1"
if [[ -n "$op" ]]; then
	shift
else
	>&2 echo "enter math expression:"
	read op
fi

require op

psql="psql -U postgres"

while test $# -gt 0
do
    case "$1" in
    --connection|-c)
	shift
	psql="$1"
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

$psql -qAtX -c "select $op"
