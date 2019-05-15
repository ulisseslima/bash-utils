#!/bin/bash

echo "keytool: $(readlink -f `which keytool`)"
echo "PATH: $PATH"

cer="$1"
if [ ! -f "$cer" ]; then
	echo "$0: creates a keystore from a cert file"
	echo "first arg must be an existing certificate file"
	exit 1
fi

pv=Private.key
while [ ! -f "$pv" ]
do
	echo "$pv is not a file"
	echo "enter private key path:"
	read pv
done

mime=$(file "$cer")
if [[ "$mime" != *'PEM certificate'* ]]; then
	echo "incorrect mime type: $mime"
	exit 1
fi

host=${cer/.cer/}
echo "this script assumes the certificate file follows the 'file.cer' naming pattern"
echo "if it doesn't, there might be unforeseen consequences."
echo ""
echo "a file $cer.keystore is going to be created for host '$host'"
echo "if that's not correct, cancel the operation with ctrl+c"
echo ""
echo "otherwise, press any key to continue..."
read cancel

#keytool -export -alias "$host" -keystore "$cer.keystore" -storepass "$password" -file "$cer"
#keytool -import -file "$cer" -storepass "$password" -alias $host -keystore "$cer.keystore"

p12=$cer.p12
#openssl x509 -in cert.crt -inform PEM -out cert.der -outform DER
openssl pkcs12 -export -in $cer -inkey $pv -out $p12

$JAVA8_HOME/bin/keytool -import -trustcacerts -alias $host -file $cer -keystore $cer.keystore
