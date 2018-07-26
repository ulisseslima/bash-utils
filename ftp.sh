#!/bin/bash -e

debug=false

do_help() {
	echo "Usage: $0 [OPTION]... "
	echo "Short script description."
	echo "-d,       --debug         print debug messages"
    echo "-h,       --help          show this help text"
    echo ""

	exit 0
}

_get() {
	path="$1"
	if [ ! -n "$path" ]; then
		echo "you need to specify target remote path with --get"
		exit 1
	fi

	f=$(basename "$path")

	echo "GET $path from $FTP_HOST..."

	ftp -np $FTP_HOST <<END_SCRIPT
		quote USER $FTP_USR
		quote PASS $FTP_PWD
		binary
		tick
		get "$path" "$f"
		quit
END_SCRIPT
}

_put() {
	localf="$1"
	remotef="$2"

	pushd .
	cd $(dirname "$localf")

	if [ ! -f "$localf" ]; then
		echo "you need to specify a local path as first argument after --put"
		exit 1
	fi

	if [ ! -n "$remotef" ]; then
		echo "you need to specify a remote path as the second argument for the --put option"
		exit 1
	fi

	echo "PUT $localf in ${FTP_USR}@${FTP_HOST} $remotef..."

	ftp -np $FTP_HOST <<END_SCRIPT
		quote USER $FTP_USR
		quote PASS $FTP_PWD
		binary
		tick
		cd "$remotef"
		put "$(basename $localf)"
		quit
END_SCRIPT

	popd
}

while test $# -gt 0
do
    case "$1" in
		--debug|-d)
			debug=true
		;;
		--help)
			do_help
		;;
		--get|-g)
			shift
			_get "$1"
		;;
		--put|-g)
			shift
			_put "$1" "$2"
		;;
		--host|-h)
			shift
			FTP_HOST="$1"
		;;
		--user|-u)
			shift
			FTP_USR="$1"
		;;
		--password|-p)
			shift
			FTP_PWD="$1"
		;;
		--*)
		    echo "invalid option: '$1'"
		    exit 1
		;;
    esac
    shift
done
