#!/bin/bash -e

HOST=''
PORT=443
# .cer file
cer=''

source $(real require.sh)

while test $# -gt 0
do
    case "$1" in
    --host|-h)
      shift
	  HOST=$1
    ;;
	--port|-p)
		shift
		PORT=$1
	;;
	--cer|-f)
		shift
		cer="$1"
		require -f "$cer"
	;;
	--fingerprint)
		require -f "$cer"
		openssl x509 -in "$cer" -noout -sha256 -fingerprint
	;;
	--print)
		require -f "$cer"
		openssl x509 -in "$cer" -noout -text
	;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

if [[ -n "$HOST" ]]; then
	openssl s_client -showcerts -verify 5 -connect $HOST:$PORT < /dev/null
fi
