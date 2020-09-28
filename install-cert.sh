#!/bin/bash

HOST=$1
if [ ! -n "$1" ]; then
	echo "first arg must be the host, followed by port on 2nd arg (if not specified, 443 is considered"
	exit 1
fi

if [[ "$1" == --check ]]; then
	if [[ ! -n "$2" ]]; then
		echo "arg 2 must be JAVA_HOME to check"
		exit 1
	fi

	keytool -list -keystore "$2/jre/lib/security/cacerts" -storepass changeit
	exit 0
fi

echo "JAVA_HOME=$JAVA_HOME"
if [ ! -n "$JAVA_HOME" ]; then
	echo "JAVA_HOME must be defined"
	exit 1
fi

kt=$(real keytool)
if [ ! -f "$kt" ]; then
	echo "keytool nout found: $kt"
	exit 1
fi
echo "keytool: $kt"

existing=$($kt -list -keystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass changeit | grep $HOST)
if [[ "$existing" == *${HOST}* ]]; then
	echo "a certificate for $HOST already exists, do you want to remove it? [Y/n]"
	echo "$existing"
	read remove

	if [[ "${remove,,}" != 'n' ]]; then
		echo "removing certificate for $HOST"
		sudo $kt -delete -alias $HOST -keystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass changeit
	else
		exit 0
	fi
fi

PORT=${2:-443}
KEYSTOREFILE="$JAVA_HOME/jre/lib/security/cacerts"
KEYSTOREPASS=changeit

echo "getting $HOST:$PORT..."
echo "continue?"
read confirmation

# get the SSL certificate
openssl s_client -connect ${HOST}:${PORT} </dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${HOST}.cert

# create a keystore and import certificate
sudo $kt -import -noprompt -trustcacerts \
    -alias ${HOST} -file ${HOST}.cert \
    -keystore ${KEYSTOREFILE} -storepass ${KEYSTOREPASS}

echo ""
echo "certificate details:"
$kt -list -keystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass changeit | grep $HOST
