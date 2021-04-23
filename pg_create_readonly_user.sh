#!/bin/bash

user="pg_readonly"

while test $# -gt 0
do
    case "$1" in
    --user|-u)
      shift
      user="$1"
    ;;
    --db|-d)
      shift
      db="$1"
    ;;
    --schema|-s)
      shift
      schema="$1"
    ;;
    --password|-p)
      shift
      password="$1"
    ;;
    -*) 
      echo "bad option '$1'"
    ;;
    esac
    shift
done

if [[ -z "$user" ]]; then
	echo "--name must not be null"
	exit 1
fi

if [[ -z "$password" ]]; then
	echo "using same password as user name"
  password="$user"
fi

if [[ -z "$db" ]]; then
	echo "--db must"
	exit 1
fi

echo "
create user $user with password '$password';
grant connect on database $db to $user;
"

if [[ -n "$schema" ]]; then
  echo "
  grant usage on schema $schema to $user;
  grant select on all tables in schema $schema to $user;
  grant usage, select on all sequences in schema $schema to $user;
  grant execute on all functions in schema $schema to $user;
  "
fi
