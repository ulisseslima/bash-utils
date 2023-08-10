#!/bin/bash -e
# runs psql on a docker postgresql instance
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

instances=$(docker ps | grep -c postgres || true)
if [[ $instances == 0 ]]; then
    echo "no docker postgresql installed"
    exit 1
elif [[ $instances == 1 ]]; then
    pg_container="$(docker ps | grep postgres | cut -d' ' -f1)"
else
    iterate.sh "$(docker ps | grep postgres)" '[$n] $line'
    while [[ -z "$pg_container" ]]; do
        echo "choose a container:"
        read container

        pg_container="$(docker ps | grep -m$container postgres | tail -n 1 | cut -d' ' -f1 || true)"
    done
fi

echo "connecting to container: $pg_container ..."
docker exec -it $pg_container psql -U postgres "$@"
