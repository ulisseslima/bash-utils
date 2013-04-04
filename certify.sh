#!/bin/bash

set -e

USER=`hostname`
PASS=123456
MODE=0
JKS=false
CACERTS_PASS=changeit
JBOSS=""

install_in_all_jres() {
	echo "encontrando instalações do java..."
	#TODO find a faster way to list java instalaltions
	ALL_CACERTS=`sudo find / -wholename "*/lib/security/cacerts" | sort -u`
	echo "$ALL_CACERTS"
	for java_cacerts in $ALL_CACERTS
	do
		echo "inserindo certificado no cacerts em $java_cacerts..."
		sudo keytool -import -noprompt -trustcacerts -alias $ALIAS -file ~/cacerts/$ALIAS.cer -keystore $java_cacerts -storepass $CACERTS_PASS
		echo "NOTA: você pode verificar se o certificado foi adicionado corretamente a essa instalação executando o comando:"
		echo "keytool -list -keystore $java_home -storepass $CACERTS_PASS | grep $ALIAS"
	done
}

if [[ ! -n "$ALIAS" ]]; then
	echo "nome do alias é obrigatório, defina seu hostname ou forneça o parâmetro --alias"
	exit 1
fi

while test $# -gt 0
do
    case "$1" in
    	--help)
    		echo "examplo full:"
    		echo "$0 --alias sictd --pass 123456 --jks --cacerts-pass 123456 --jboss /caminho/home/jboss"
    		echo "examplo apenas instalação:"
    		echo "$0 --alias sictd --cacerts-pass 123456 --install"
    		exit 0
    	;;		
		--alias|-a) shift
			USER=$1
        ;;
		--pass|p) shift
			PASS=$1			
        ;;
        --jks)
        	JKS=true
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

mkdir -p ~/cacerts

echo "usando alias '$ALIAS' e senha '$PASS'..."

echo "gerando certificado e keystore..."
keytool -genkey -alias $ALIAS -keyalg RSA -keystore ~/cacerts/$ALIAS.keystore -storepass $PASS -keypass $PASS -dname "CN=$ALIAS, OU=CONTEXPRESS, O=MURAH, L=SAOPAULO, ST=SP, C=BR"

echo "exportando o certificado no keystore..."
keytool -export -alias $ALIAS -keystore ~/cacerts/$ALIAS.keystore -storepass $PASS -file ~/cacerts/$ALIAS.cer

if [ "$JKS" == "true" ]; then
	echo "gerando jks para conexão com o desktop..."
	keytool -import -file ~/cacerts/$ALIAS.cer -alias $ALIAS -keystore $ALIAS.jks
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
    echo "exemplo de connector do Jboss criado em ~/cacerts/server.xml.snippet"
fi

install_in_all_jres

echo "testando conectividade do alias selecionado..."
ping -c 3 $ALIAS
