#!/bin/bash
# generates p12, jks, cer, keystore certs from a hostname
set -e

ALIAS=`hostname`
PASS=123456
MODE=0
JKS=false
CACERTS_PASS=changeit
VALID_DAYS=3650
JBOSS=""

check_alias() {
	if [[ ! -n "$ALIAS" ]]; then
		echo "alias is required, define your hostname or provide one with --alias"
		exit 1
	fi
}

install_in_all_jres() {
	check_alias

	echo "finding java installations (can take a while)..."
	#TODO find a faster way to list java installations to all jres
	ALL_CACERTS=`sudo find / -wholename "*/lib/security/cacerts" | sort -u`
	echo "$ALL_CACERTS"
	for java_cacerts in $ALL_CACERTS
	do
		echo "installing certificate to $java_cacerts..."
		keytool -import -noprompt -trustcacerts -alias $ALIAS -file ~/cacerts/$ALIAS.cer -keystore "$java_cacerts" -storepass "$CACERTS_PASS"
		echo "NOTE: you can verify that the certificate was added correctly to this installation with the command:"
		echo "keytool -list -keystore $java_cacerts -storepass $CACERTS_PASS | grep $ALIAS"
	done
}

while test $# -gt 0
do
    case "$1" in
    	--help)
    		echo "full example:"
    		echo "$0 --alias foo --pass 123456 --jks --cacerts-pass 123456 --jboss /jboss/home"
    		echo "examplo apenas instalação:"
    		echo "$0 --alias foo --cacerts-pass 123456 --install"
    		exit 0
    	;;
		--alias|-a) shift
			ALIAS=$1
			echo "defined alias as $ALIAS"
        ;;
		--pass|p) shift
			PASS=$1
        ;;
        --jks)
        	JKS=true
        ;;
        --validity) shift
        	VALID_DAYS=$1
        ;;
        --cacerts-pass) shift
        	CACERTS_PASS=$1
        ;;
        --jboss) shift
        	JBOSS=$1
        ;;
        --install|-i)
	        install_in_all_jres
        	exit 0
        ;;
		--*) echo "bad option $1"
			exit 1
        ;;
    esac
    shift
done

check_alias

mkdir -p ~/cacerts

echo "using alias '$ALIAS' and password '$PASS'..."

kf="$HOME/cacerts/$ALIAS.keystore"
cf="$HOME/cacerts/$ALIAS.cer"
jf="$HOME/cacerts/$ALIAS.jks"
pf="$HOME/cacerts/$ALIAS.pem"
p12="$HOME/cacerts/$ALIAS.p12"

if [[ ! -f "$kf" ]]; then
	echo "generating certificate and keystore..."
	keytool -genkey -alias $ALIAS -keyalg RSA -validity $VALID_DAYS -keystore "$kf" -storepass "$PASS" -keypass "$PASS" -dname "CN=$ALIAS, OU=DEV, O=DVLCUBE, L=WORLD, ST=AW, C=US"
else
	echo "file already exists, skipping: $kf"
fi

if [[ ! -f "$cf" ]]; then
	echo "exporting certificate to keystore..."
	keytool -export -alias $ALIAS -keystore "$kf" -storepass "$PASS" -file "$cf"
fi

#if [[ ! -f "$pf" ]]; then
#	echo "creating .pem..."
#	openssl pkcs7 -in "$cf" -print_certs -out "$pf"
#fi

if [[ ! -f "$p12" ]]; then
	echo "creating .p12..."
	#openssl pkcs12 -export -out "$p12" -inkey "$pf" -in "$pf"
	keytool -genkeypair -alias $ALIAS -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore "$p12" -validity 3650 -storepass "$PASS" \
		-dname "CN=$ALIAS, OU=DEV, O=DVLCUBE, L=WORLD, ST=AW, C=US"
fi

if [ "$JKS" == "true" ]; then
	echo "generating jks..."
	keytool -import -file "$cf" -alias $ALIAS -keystore "$jf"
fi

if [[ -n "$JBOSS" ]]; then
	mkdir -p "$JBOSS/cacerts"
	cp ~/cacerts/$ALIAS.keystore "$JBOSS/cacerts"
	echo "<!-- HTTPS -->
   	<Connector port=\"8443\" protocol=\"HTTP/1.1\" SSLEnabled=\"true\"
       maxThreads=\"1500\" scheme=\"https\" secure=\"true\"
       clientAuth=\"false\" sslProtocol=\"TLS\"
       address=\"\${jboss.bind.address}\" strategy=\"ms\"
       keystoreFile=\"$JBOSS/cacerts/$ALIAS.keystore\"
       keystorePass=\"$PASS\" />" > ~/cacerts/server.xml.snippet
    echo "connector template for Jboss created in ~/cacerts/server.xml.snippet"
fi

install_in_all_jres

echo "testing alias conectivity..."
ping -c 3 $ALIAS
