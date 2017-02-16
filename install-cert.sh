#!/bin/bash

if [ ! -n "$JAVA_HOME" ]; then
	echo "JAVA_HOME must be defined"
	exit 1
fi

HOST=$1
if [ ! -n "$1" ]; then
	echo "first arg must be the host"
	exit 1
fi

PORT=${2:-443}
KEYSTOREFILE=$JAVA_HOME/jre/lib/security/cacerts
KEYSTOREPASS=changeit

echo "getting $HOST:$PORT..."

# get the SSL certificate
openssl s_client -connect ${HOST}:${PORT} </dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${HOST}.cert

# create a keystore and import certificate
sudo keytool -import -noprompt -trustcacerts \
    -alias ${HOST} -file ${HOST}.cert \
    -keystore ${KEYSTOREFILE} -storepass ${KEYSTOREPASS}

# verify we've got it.
keytool -list -v -keystore ${KEYSTOREFILE} -storepass ${KEYSTOREPASS} -alias ${HOST}
