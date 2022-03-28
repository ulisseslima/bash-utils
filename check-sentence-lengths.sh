#!/bin/bash
# generates warnings if a sentence is too big. Helps write more readable text.

file="$1"
if [[ ! -f "$file" ]]; then
	rmf=$(mktemp /tmp/XXX-check)
	echo "$file" > "$rmf"
	file="$rmf"
fi

max=20
verbose=false

function info() {
	if [[ $verbose == true ]]; then
		>&2 echo "$@"
	fi
}

while test $# -gt 0
do
    case "$1" in
    --verbose|-v)
      verbose=true
    ;;
    --max-words|-m)
      shift
      max=$1
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

err=0
sentences=0
while read line
do
	info $line
	words=$(echo "$line" | wc -w)
	if [[ $words -gt $max ]]; then
		[[ $verbose != true ]] && echo $line
		echo "└ sentence too big ($words/$max)"
		err=1
	fi
	info "=$words"

	sentences=$((sentences+1))
done < <(cat "$file" | tr '.' '\n')

echo "total sentences: $sentences"

[[ -f "$rmf" ]] && rm "$rmf"

exit $err
