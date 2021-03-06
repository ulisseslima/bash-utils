#!/bin/bash -e

verbose=false
debug=false

do_help() {
	echo "describes a file based on its extension"
	echo "currently supports:"
	echo "*.java"
	exit 0
}

log() {
	if [ $verbose == true ]; then
		echo "$1"
	fi
}

debug() {
	if [ $debug == true ]; then
		echo "$1"
	fi
}

desc_java() {
	file="$1"
	javadoc=$(awk '/\/\*\*/ {p=1}; p; /\*\// {p=0}' "$file" | grep -v '/' | grep -v '@' | tr -d '*' | sed -e 's/^[[:space:]]*//')
	members=$(grep private "$file" | cut -d' ' -f2,3)

	echo "$javadoc"
	echo ""
	echo "Members:"
	echo "$members" | while read member
	do
		t=$(echo "$member" | cut -d' ' -f1)
		name=$(echo "$member" | cut -d' ' -f2 | tr -d ';')
		echo "* $name ($t);"
	done
}

if [ ! -f "$1" ]; then
	echo "first argument must be a file"
	exit 1
fi

file="$1"
shift

while test $# -gt 0
do
    case "$1" in
		--verbose|-v) 
		    verbose=true
		;;
		--debug|-d)
			debug=true
		;;
		--help|-h)
			do_help
		;;
		--*)
		    echo "invalid option: '$1'"
		    exit 1
		;;
    esac
    shift
done

case "$file" in
	*.java) 
	    log "lendo arquivo $file"
	    desc_java "$file"
	;;
	*.*)
		format=$(echo "$file" | rev | cut -d'.' -f1 | rev)
	    echo "unsupported format: '$format'"
	    exit 1
	;;
	*)
		echo "file has no extension: $file"
		exit 1
	;;
esac
shift

