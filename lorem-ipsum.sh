#!/bin/bash -e
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $MYDIR/log.sh
source $(real require.sh)

trap 'catch $? $LINENO' ERR
catch() {
  err "status $1 on line $2:"
  code=$(cat $MYSELF | head -86 | tail -1)
  echo "$code"

  err -n "words=$words"
  err "line_no=$line_no"
  err "paragraph=$paragraph"
  err "count=$count"
  err "wpl=$wpl"
  err line=$line
}

do_help() {
    echo "create documents with random words."
}

out=/tmp/lorem.out

line_no=0
count=0

words=50
dictionary=$DEFAULT_DICTIONARY
wpl=10
paragraph=10

while test $# -gt 0
do
    case "$1" in
        --help|-h)
            do_help
            exit 0
        ;;
        --verbose|-v)
            debugging on
        ;;
        --words|-w)
            shift
            words="$1"
            debug "words: $words"
        ;;
        --per-line|-c)
            shift
            wpl="$1"
            debug "words per line: $wpl"
        ;;
        --lines-per-paragraph|-p)
            shift
            paragraph="$1"
            debug "lines per paragraph: $wpl"
        ;;
        --dictionary|-d)
            shift
            dictionary="$1"
            if [ ! -f "$dictionary" ]; then
                err "not a file: '$dictionary'"
                exit 1
            fi
            debug "words on dictionary: $(wc -l $dictionary)"
        ;;
        -*)
            echo "bad option '$1'"
        ;;
    esac
    shift
done

require dictionary "a dictionary file is required. a dictionary should contain one word per line. specify with -d"

while true
do
    line=$(shuf -rn $wpl $dictionary)
    echo ${line^}.

    line_no=$((line_no+1))
    [[ $((line_no % paragraph)) == 0 ]] && echo ""

    ((count+=wpl)); [[ $count -ge $words ]] && break
done

debugging off
