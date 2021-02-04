#!/bin/bash
# cria um usuário do postgres

if [[ "$1" == --help ]]; then
	echo "1: db"
	echo "2: user"
	echo "3: pass"
	echo "4: host"
	echo "5: port"
	exit 0
fi

db="$1"
if [[ ! -n "$db" ]]; then
	echo "first argument must be the database"
	exit 1
fi

user="${2}"
if [ ! -n "$user" ]; then
	echo "second argument must be the user to create"
	exit 1
fi

password="${3:-pass123}"

schema='public'
if [[ "$user" == *.* ]]; then
	schema=$(echo $user | cut -d'.' -f2)
fi

host="${4:-localhost}"
port="${5:-5432}"

sql="CREATE USER $user WITH PASSWORD '$password';
GRANT ALL PRIVILEGES ON DATABASE $db to $user;
grant all privileges on schema $schema to $user;

grant all privileges on all tables in schema $schema to $user;
grant all privileges on all sequences in schema $schema to $user;

alter default privileges in schema $schema grant all on tables to $user;
alter default privileges in schema $schema grant all on sequences to $user;

alter default privileges in schema public grant all on tables to $user;
alter default privileges in schema public grant all on sequences to $user;

alter user $user with superuser;
"

if [[ "$password" == '--update' || "$4" == '--update' ]]; then
	sql=$(echo "$sql" | tail --lines=+2)
fi

echo "$sql"
echo "-------------------------"
echo "will create user '$user' with password '$password' on schema '$schema' with all privileges on db '$db'"
echo "press enter to confirm or ctrl c to cancel"
read confirmation

psql -U postgres -h $host -p $port -c "$sql"
