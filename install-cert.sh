#!/bin/bash -e
# downloads and installs a certificate from a remote host. removes the existing one if wanted
# $0 -h host -p port
# public logs: https://crt.sh/?q=google.com

HOST=''
PORT=443
CERTF=
KEYSTOREPASS=changeit
just_check=false

if [ ! -t 0 ]; then
	echo "reading certificate from stdin..."
	CERTF=/dev/stdin
fi

while test $# -gt 0
do
    case "$1" in
	--cert|-f)
		shift
		CERTF="$1"
	;;
    --host|-h)
      	shift
	  	HOST=$1
    ;;
	--port|-p)
		shift
		PORT=$1
	;;
	--java-home)
		shift
		JAVA_HOME="$1"
	;;
	--keytool)
		shift
		kt="$1"
	;;
	--cacerts)
		shift
		cacerts="$1"
	;;
	--help)
                echo "e.g.:"
		echo "$0 --host some.host --port 10443 --java-home $JAVA_HOME"
        ;;
	--cacerts-pass|--passwd)
		shift
		KEYSTOREPASS="$1"
	;;
    --check)
	  	just_check=true
    ;;
    -*)
      	echo "bad option '$1'"
    ;;
    esac
    shift
done

if [[ -z "$HOST" ]]; then
	echo "specify target host with --host"
	exit 1
fi
echo "# using HOST=$HOST"
echo "# using PORT=$PORT"
echo "# using CERTF=$CERTF"

echo "# using JAVA_HOME=$JAVA_HOME"
if [ ! -d "$JAVA_HOME" ]; then
	echo "JAVA_HOME must be defined as an existing directory: '$JAVA_HOME'"
	exit 1
fi

[[ -z "$kt" ]] && kt="$JAVA_HOME/bin/keytool"
if [ ! -f "$kt" ]; then
	echo "keytool not found: '$kt'"
	exit 1
fi
echo "# using keytool=$kt"

if [[ -z "$cacerts" ]]; then
	cacerts="$(find $JAVA_HOME -name cacerts -print -quit)"
fi
echo "# using cacerts=$cacerts"
echo "# using KEYSTOREPASS=$KEYSTOREPASS"
# determine whether we need to run keytool under sudo (if we can't write to the keystore)
SUDO=""
if [ -e "$cacerts" ]; then
	if [ ! -w "$cacerts" ]; then
		SUDO="sudo"
	fi
else
	parentdir="$(dirname "$cacerts")"
	if [ ! -w "$parentdir" ]; then
		SUDO="sudo"
	fi
fi

if [ -n "$SUDO" ]; then
	if ! command -v sudo >/dev/null 2>&1; then
		echo "No write permission for $cacerts and sudo is not available; please run this script as a user who can write $cacerts or install sudo"
		exit 1
	fi
	echo "# will use sudo for keystore operations"
fi

# helper to run keytool, optionally under sudo
run_kt() {
	if [ -n "$SUDO" ]; then
		"$SUDO" "$kt" "$@"
	else
		"$kt" "$@"
	fi
}

existing=$(run_kt -list -keystore "$cacerts" -storepass "$KEYSTOREPASS" 2>/dev/null | grep "$HOST" || true)
if [[ "$existing" == *${HOST}* ]]; then
	echo "a certificate for $HOST already exists, do you want to remove it? [Y/n]"
	echo "$existing"
	read remove

	if [[ "${remove,,}" != 'n' ]]; then
		echo "removing certificate for $HOST"
		run_kt -delete -alias "$HOST" -keystore "$cacerts" -storepass "$KEYSTOREPASS" || true
	else
		exit 0
	fi
fi

if [[ "$just_check" == true ]]; then
	run_kt -list -keystore "$cacerts" -storepass "$KEYSTOREPASS" | grep "$HOST"
	exit 0
fi

RAW_CERT_DIR=$(dirname $cacerts)

if [[ -n "$HOST" ]]; then
	echo "will download and install ssl certificate from $HOST:$PORT ..."
	echo "continue?"
	read confirmation

	CERTF=$RAW_CERT_DIR/${HOST}.cer

	# get the SSL certificate
	openssl s_client -connect ${HOST}:${PORT} </dev/null \
		| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $CERTF
fi

# create a keystore and import certificate
run_kt -import -noprompt -trustcacerts \
	-alias "${HOST}" -file "$CERTF" \
	-keystore "$cacerts" -storepass "$KEYSTOREPASS"

echo ""
echo "certificate details:"
run_kt -list -keystore "$cacerts" -storepass "$KEYSTOREPASS" | grep "$HOST" || true
