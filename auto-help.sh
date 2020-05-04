#!/bin/bash
# automates doc creation. to work, other scripts must:
# 1. `source` this script
# 2. all functions that have docs need to be declared using the "function" command
# 3. doc able functions must have a single line of comment above it
# 4. function names must match script args. e.g.: 'function do_stuff' will consider arg '--do-stuff'.

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
MYNAME="$(basename $SOURCE)"

doc_src="$(readlink -f $0)"
doc_src_name=$(basename $doc_src)

help_docs() {
    if [[ ! -f "$doc_src" ]]; then
        echo "doc_src is not a file: '$doc_src'"
        exit 1
    fi

    while read def
    do
        case "$def" in
            '#'*)
                echo "$def"
            ;;
            *'()'*)
                arg=$(echo $def | cut -d' ' -f2 | cut -d'(' -f1)
                echo "--${arg//_/-}"
            ;;
            *)
                echo ""
            ;;
        esac
    done < <(grep -B1 -P 'function (.*)\(\)' "$doc_src")
}

if [[ $SOURCE == "$doc_src" ]]; then
    doc_src="$1"
    help_docs
fi