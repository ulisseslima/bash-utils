#!/bin/bash
# performs a search on an ldap server

source $(real require.sh)

while test $# -gt 0
do
    case "$1" in
    --query|-q)
      shift
      query="$1"
    ;;
    --user|-u)
      shift
      user="$1"
    ;;
    --pass|-p)
      shift
      pass="$1"
    ;;
    --host|-h)
      shift
      host="$1"
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

require host
require query

if [[ -z "$user" ]]; then
	ldapsearch -x -LLL -h $host -b "$query"
else
	require pass
	ldapsearch -x -LLL -h $host -D "$user" -w "$pass" -b "$query"
fi
