#!/bin/bash
# downloads a site ssl certificate and installs to java cacerts

storepass=changeit

HOST=$1
if [ ! -n "$1" ]; then
	echo "first arg must be the host, followed by port on 2nd arg (if not specified, 443 is considered"
	exit 1
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

existing=$($kt -list -keystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass $storepass | grep $HOST)
if [[ "$existing" == *${HOST}* ]]; then
	echo "a certificate for $HOST already exists:"
	echo "$existing"
	echo "in the future, use this command if you want to remove it:"
	echo "sudo $kt -delete -alias $HOST -keystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass $storepass"
fi

PORT=${2:-443}
KEYSTOREFILE="$JAVA_HOME/jre/lib/security/cacerts"

echo "getting $HOST:$PORT..."

# get the SSL certificate
openssl s_client -connect ${HOST}:${PORT} </dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${HOST}.cert

echo ""
echo "java certificate info (might be empty if not installed):"
$kt -list -keystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass $storepass | grep $HOST

echo ""
echo "downloaded cert:"
echo "${HOST}.cert"

echo ""
cat ${HOST}.cert