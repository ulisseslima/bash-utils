#!/bin/bash

# remove files recursively under DIR that are older than DATE (yyyy-MM-dd)

do_help() {
	echo "Usage: $(basename "$0") [--dry-run] <dir> <yyyy-MM-dd>"
	echo "  Removes files recursively under <dir> older than <yyyy-MM-dd>"
}

dry_run=false

while test $# -gt 0
do
	case "$1" in
		--dry-run)
			dry_run=true
			shift
		;;
		--help|-h)
			do_help
			exit 0
		;;
		--*)
			echo "bad option $1"
			exit 1
		;;
		*)
			break
		;;
	esac
done

dir="$1"
date_str="$2"

if [ -z "$dir" ] || [ -z "$date_str" ]; then
	do_help
	exit 1
fi

if [ ! -d "$dir" ]; then
	echo "diretório $dir não encontrado"
	exit 1
fi

if ! date -d "$date_str" >/dev/null 2>&1; then
	echo "data inválida: $date_str (use yyyy-MM-dd)"
	exit 1
fi

# reference file whose mtime marks the cutoff
ref_file="$(mktemp)"
trap 'rm -f "$ref_file"' EXIT
touch -d "$date_str" "$ref_file"

if [ "$dry_run" == "true" ]; then
	find "$dir" -type f ! -newer "$ref_file" -print
	find "$dir" -mindepth 1 -type d -empty -print
else
	find "$dir" -type f ! -newer "$ref_file" -print -delete
	# repeat to catch dirs left empty after removing nested empty dirs
	while [ -n "$(find "$dir" -mindepth 1 -type d -empty -print -delete)" ]; do :; done
fi
