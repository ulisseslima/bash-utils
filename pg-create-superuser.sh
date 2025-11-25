#!/bin/bash
source $(real require.sh)

if [[ $# == 0 ]]; then
  echo "usage example:"
  echo "$0 -u username -p desiredpass"
  echo ""
  echo "This creates a superuser that can login to PostgreSQL without using the postgres account"
fi

while test $# -gt 0
do
    case "$1" in
    --user|-u)
	shift
      	user=$1
    ;;
    --pass|-p)
	shift
      	password=$1
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

require user
require password

echo "Execute this as the postgres user or another superuser:"
echo "
CREATE USER $user WITH PASSWORD '$password' SUPERUSER CREATEDB CREATEROLE LOGIN;
"

echo ""
echo "After creating the user, you can login with:"
echo "psql -U $user -d postgres"
