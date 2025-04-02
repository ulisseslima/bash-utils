#!/bin/bash
# performs a search on an ldap server

source $(real require.sh)

while test $# -gt 0
do
    case "$1" in
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
      host="$1" # include port if not 389
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

require user
require pass
require host

#echo ldapwhoami -vvv -h $host -p 389 -D "$user" -x -w "$pass"
#ldapwhoami -vvv -h $host -p 389 -D "$user" -x -w "$pass"
ldapwhoami -vvv -H "ldap://${host}" -D "$user" -x -w "$pass"
