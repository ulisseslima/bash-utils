#!/bin/bash

###########################
# Cria um certificado para ser usado com o servidor da caixa
# $1 nome do usuário
# $2 senha (opcional)
# $3 para dar override em $JAVA_HOME
#
# verificando que o alias está registrado:
# keytool -list -keystore $myjavahome/jre/lib/security/cacerts
# para cada cliente
# keytool -import -noprompt -trustcacerts -alias sictd -file sictd.cer -keystore $myjavahome/jre/lib/security/cacerts -storepass changeit
###########################

set -e

JBOSS_CERT_DIR=/home/wonka/proj/servers/jboss/caixa/server/teste/certificados
USER=$1
PASS=123456
if [[ -n $2 ]]; then
PASS="$2"
fi
if [[ -n $3 ]]; then
JAVA_HOME="$3"
fi

# MODE:
# 0: full. Creates a certificate for the server, exports it, the
MODE=0

DIR_CACERTS="$JAVA_HOME"/jre/lib/security
if [ ! -d "$DIR_CACERTS" ]; then
  echo "Diretório do cacerts não existe: '$DIR_CACERTS'"
  exit 1
fi

while test $# -gt 0
do
    case "$1" in
    	--help)
    		echo "example: $0 -u user -p password --port 22"
    		exit 0
    	;;
		--java|-j) shift
			JAVA_HOME=$1
        ;;
		--alias|-a) shift
			USER=$1
        ;;
		--pass|p) shift
			PASS=$1			
        ;;
        --client|-c) shift
        	PORT_GT=$1
        ;;
		--*) echo "bad option $1"
			exit 1
        ;;
    esac
    shift
done

cd ~
keytool -genkey -alias $USER -keyalg RSA -keystore $USER.keystore -storepass $PASS -keypass $PASS -dname "CN=$USER, OU=CONTEXPRESS, O=MURAH, L=SAOPAULO, ST=SP, C=BR"

echo "exportando o certificado com o alias no alias.keystore..."
keytool -export -alias $USER -keystore $USER.keystore -storepass $PASS -file $USER.cer

cd "$DIR_CACERTS"
echo "senha padrão do cacerts: changeit"
keytool -import -file ~/$USER.cer -alias $USER -keystore cacerts

cd ~
echo "Gerando jks para conexão com o desktop"
keytool -import -file ~/$USER.cer -alias $USER -keystore sictd.jks

echo "concluído."
echo "certifique-se de que o nome $USER está definido como alias do 127.0.0.1 no arquivo hosts"
ping -c 3 $USER

echo "copying certificate to jboss dir"
cp $USER.keystore $JBOSS_CERT_DIR

keytool -import -noprompt -trustcacerts -alias sictd -file sictd.cer -keystore $myjavahome/jre/lib/security/cacerts -storepass changeit
