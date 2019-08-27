#!/bin/bash

cer=$1

if [ ! -f "$cer" ]; then
	echo "first argument must be a file"
	exit 1
fi

if [[ $(file "$cer" | grep -c "PEM certificate") -lt 1 ]]; then
	echo "certificate must be a PEM certificate"
	exit 1
fi

openssl pkcs12 -export -in $cer -inkey audixpress.plugin.key -chain -CAfile $cer -name "audixpress.plugin" -out audixpress.plugin.p12
keytool -importkeystore -deststorepass MY-KEYSTORE-PASS -destkeystore audixpress.jks -srckeystore audixpress.plugin.p12 -srcstoretype PKCS12

