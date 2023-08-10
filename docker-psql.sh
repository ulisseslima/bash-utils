#!/bin/bash -e
# runs psql on a docker postgresql instance
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

user=postgres
instance=postgres

while test $# -gt 0
do
    case "$1" in
    --help|-h)
      do_help
      exit 0
    ;;
    -U|--user)
      shift
      user=$1
    ;;
    -i|--instance)
      shift
      instance=$1
    ;;
    --extra|-e)
      shift
      extra="$@"
    ;;
    -*)
      echo "bad option '$1'"
      exit 1
    ;;
    esac
    shift
done

instances=$(docker ps | grep -c $instance || true)
if [[ $instances == 0 ]]; then
    echo "no docker $instance installed"
    exit 1
elif [[ $instances == 1 ]]; then
    pg_container="$(docker ps | grep $instance | cut -d' ' -f1)"
else
    iterate.sh "$(docker ps | grep $instance)" '[$n] $line'
    while [[ -z "$pg_container" ]]; do
        echo "choose a container:"
        read container

        pg_container="$(docker ps | grep -m$container $instance | tail -n 1 | cut -d' ' -f1 || true)"
    done
fi

echo "connecting to container: $pg_container ..."
docker exec -it $pg_container psql -U $user $extra
