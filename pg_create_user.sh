#!/bin/bash
source $(real require.sh)

while test $# -gt 0
do
    case "$1" in
    --user|-u)
	shift
      	user=$1
    ;;
    --db|-d)
	shift
      	database=$1
    ;;
    --schema|-s)
	shift
      	schema=$1
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
require database
require schema
require password

echo "
CREATE USER $user WITH PASSWORD '$password';
grant connect on database $database to $user;
grant usage on schema $schema to $user;
grant select, insert, update, delete on all tables in schema $schema to $user;
grant usage, select, update on all sequences in schema $schema to $user;
grant execute on all functions in schema $schema to $user;
"
