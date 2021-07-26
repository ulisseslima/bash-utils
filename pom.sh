#!/bin/bash -e
# depends on: xmlstarlet
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real log.sh)

NAMESPACE='http://maven.apache.org/POM/4.0.0'

function do_select() {
    local file="$1"
    local query="$2"

    require.sh -f "$file" "arg 1 should be the pom file location"
    require.sh "$query" "arg 2 should be the xpath query, maven pom namespace prefix is 'x:'"

    xmlstarlet sel -N x=$NAMESPACE -t -v "$query" $file
}

function do_edit() {
    local file="${1}"
    local query="$2"
    local value="$3"

    currval=$(do_select "$file" "$query")
    require.sh "$value" "arg 3 should be the replacement value"

    debug "editing $file $query from $currval to $value..."
    xmlstarlet ed -L -N x=$NAMESPACE \
        -u "$query" -v "$value" \
        $file
    debug "value changed."

    if [[ -n "$dependents" ]]; then
        >&2 echo "changing dependents: $dependents"

        dependency=$(dirname $file | rev | cut -d'/' -f1 | rev)

        while read dependent
        do
            if [[ -f $dependent ]]; then
                >&2 echo "changing $dependency on $dependent to $value ..."
                xmlstarlet ed -L -N x=$NAMESPACE \
                    -u "x:project/x:dependencyManagement/x:dependencies/x:dependency[x:artifactId='$dependency']/x:version" -v "$value" \
                    $dependent
            fi
        done < <(echo "$dependents" | tr ' ' '\n')
    fi
}

# selects project version, or parent version, if undefined.
function select_version() {
    local file="$1"
    if [[ -d "$file" ]]; then
        file="$file/pom.xml"
    fi

    if [[ ! -f "$file" ]]; then
        err "arg 1 must be a pom file"
        exit 1
    fi

    local v=$(do_select "$file" 'x:project/x:version' || true)
    if [[ ! -n "$v" ]]; then
        debug "falling back to parent/version..."
        v=$(do_select "$file" 'x:project/x:parent/x:version')
    fi

    echo "$v"
}

function set_version() {
    local file="$1"
    local new_v="$2"

    local v=$(do_select "$file" 'x:project/x:version' || true)
    if [[ ! -n "$v" ]]; then
        debug "falling back to parent/version..."
        do_edit "$file" "x:project/x:parent/x:version" "$new_v"
    else
        do_edit "$file" "x:project/x:version" "$new_v"
    fi
}

##
# increments build version.
# if SNAPSHOT, just closes it without incrementing.
function bump_build() {
    local file="$1"
    if [[ -d "$file" ]]; then
        file="$file/pom.xml"
    fi

    if [[ ! -f "$file" ]]; then
        err "arg 1 must be a pom file"
        exit 1
    fi

    local v=$(select_version "$file")

    if [[ "$v" == *SNAPSHOT* ]]; then
        debug "only closing snapshot..."
        new_v=${v/-SNAPSHOT/}
    else
        new_v=$(echo $v | awk -F. '{$NF+=1; OFS="."; print $0}' | sed 's/ /./g')
        debug "new version calculated as: $new_v"
    fi
    
    do_edit "$file" "x:project/x:version" "$new_v"
    echo $new_v
}

function reopen_version() {
    local file="$1"
    local v=$(select_version "$file")

    if [[ "$v" == *SNAPSHOT* ]]; then
        debug "project is already in snapshot"
    else
        new_v="$(bump_build "$file")-SNAPSHOT"
    fi

    do_edit "$file" "x:project/x:version" "$new_v"
    echo "$new_v"
}

while test $# -gt 0
do
    case "$1" in
        --verbose|-v) 
            debugging on
        ;;
        --file|-f)
            shift
            f="$1"
        ;;
        --dependents)
            shift
            dependents="$1"
        ;;
        --select|-s)
            if [[ -z "$f" ]]; then
                shift; f="$1"
            fi
            shift; q="$1"

            do_select "$f" "$q"
        ;;
        --edit|-e)
            if [[ -z "$f" ]]; then
                shift; f="$1"
            fi
            shift; query="$1"
            shift; value="$1"

            do_edit "$file" "$query" "$value"
        ;;
        --project-version|--version)
            if [[ -z "$f" ]]; then
                shift; f="$1"
            fi
            select_version "$f"
        ;;
        --set)
            if [[ -z "$f" ]]; then
                shift; f="$1"
            fi
            shift; version="$1"
            set_version "$f" "$version"
        ;;
        --bump-build|--bump|-b)
            if [[ -z "$f" ]]; then
                shift; f="$1"
            fi
            bump_build "$f"
        ;;
        --snap|--open|-o)
            if [[ -z "$f" ]]; then
                shift; f="$1"
            fi
            reopen_version "$f"
        ;;
        -*)
            echo "bad option '$1'"
            exit 1
        ;;
    esac
    shift
done