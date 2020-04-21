#!/bin/bash -e
# depends on: xmlstarlet
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $MYDIR/log.sh

NAMESPACE='http://maven.apache.org/POM/4.0.0'

function do_select() {
    file="$1"
    query="$2"

    require.sh -f "$file" "arg 1 should be the pom file location"
    require.sh "$query" "arg 2 should be the xpath query, maven pom namespace prefix is 'x:'"

    xmlstarlet sel -N x=$NAMESPACE -t -v "$query" $file
}

function do_edit() {
    file="${1}"
    query="$2"
    value="$3"

    currval=$(do_select "$query" "$file")
    require.sh "$value" "arg 3 should be the replacement value"

    debug "editing $file $query from $currval to $value..."
    xmlstarlet ed -L -N x=$NAMESPACE \
        -u "$query" -v "$value" \
        $file
    debug "value changed."
}

# selects project version, or parent version, if undefined.
function select_version() {
    v=$(do_select "$1" 'x:project/x:version' || true)
    if [[ ! -n "$v" ]]; then
        debug "falling back to parent/version..."
        v=$(do_select "$1" 'x:project/x:parent/x:version')
    fi

    echo "$v"
}

while test $# -gt 0
do
    case "$1" in
        --verbose|-v) 
            debugging on
        ;;
        --select|-s)
            shift; file="$1"
            shift; query="$1"

            do_select "$file" "$query"
        ;;
        --edit|-e)
            shift; file="$1"
            shift; query="$1"
            shift; value="$1"

            do_edit "$file" "$query" "$value"
        ;;
        --project-version|--version)
            shift; file="$1"
            select_version "$file"
        ;;
        -*)
            echo "bad option '$1'"
        ;;
    esac
    shift
done