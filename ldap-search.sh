#!/bin/bash
# performs a search on an ldap server

# examples:
# ldap-search.sh -h ldap.host -u cn=Manager,o=corp -q uid=username,ou=People,o=corp
# ldap-search.sh -h ldap.host -u cn=Manager,o=corp -q ou=Groups,o=corp
# ldapsearch -D "cn=Manager,o=corp" -w passw -H 'ldap://ldap.host:389' -b "o=corp" -s sub -x "(objectclass=*)"

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
      # if not using default port, specify host:port
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
	ldapsearch -x -LLL -H "ldap://${host}" -b "$query"
else
	if [[ -z "$pass" ]]; then
		ldapsearch -x -LLL -H "ldap://${host}" -D "$user" -W -b "$query"
	else
		ldapsearch -x -LLL -H "ldap://${host}" -D "$user" -w "$pass" -b "$query"
	fi
fi
