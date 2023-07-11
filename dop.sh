#!/bin/bash -e
# date ops using local postgres

source $(real require.sh)

op="$1"
if [[ -n "$op" ]]; then
	shift
	if [[ "$op" == now ]]; then
		op="now()"
	fi
else
	>&2 echo "enter date expression (e.g.: 2022-01-01 +days 30):"
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
    --verbose|-v|-d|--debug)
	shift
	psql="$1"
    ;;
    +minutes)
	shift
	op="'${op}'::timestamp +interval '$1 minutes'"
    ;;
    +hours)
	shift
	op="'${op}'::timestamp +interval '$1 hours'"
    ;;
    +days)
	shift
	op="'${op}'::timestamp +interval '$1 days'"
    ;;
    +weeks)
	shift
	op="'${op}'::timestamp +interval '$1 weeks'"
    ;;
    +months)
	shift
	op="'${op}'::timestamp +interval '$1 months'"
    ;;
    +years)
	shift
	op="'${op}'::timestamp +interval '$1 years'"
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

$psql -qAtX -c "select $op"
