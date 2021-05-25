#!/bin/bash -e

HOST=''
PORT=443
CERTF=
KEYSTOREPASS=changeit
just_check=false

first_byte=$(dd bs=1 count=1 2>/dev/null | od -t o1 -A n | tr -dc 0-9)
if [ -n "$first_byte" ]; then
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

existing=$($kt -list -keystore "$cacerts" -storepass "$KEYSTOREPASS" | grep $HOST || true)
if [[ "$existing" == *${HOST}* ]]; then
	echo "a certificate for $HOST already exists, do you want to remove it? [Y/n]"
	echo "$existing"
	read remove

	if [[ "${remove,,}" != 'n' ]]; then
		echo "removing certificate for $HOST"
		$kt -delete -alias $HOST -keystore "$cacerts" -storepass "$KEYSTOREPASS"
	else
		exit 0
	fi
fi

if [[ "$just_check" == true ]]; then
	$kt -list -keystore "$cacerts" -storepass $KEYSTOREPASS | grep $HOST
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
$kt -import -noprompt -trustcacerts \
    -alias ${HOST} -file $CERTF \
    -keystore ${cacerts} -storepass ${KEYSTOREPASS}

echo ""
echo "certificate details:"
$kt -list -keystore "$cacerts" -storepass $KEYSTOREPASS | grep $HOST || true
