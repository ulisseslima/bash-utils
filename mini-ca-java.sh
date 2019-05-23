#!/bin/bash -e
source /etc/profile

keytool="keytool"

while test $# -gt 0
do
    case "$1" in
		--keytool|-k)
			shift
			keytool="$1"
			echo "changed keytool bin to: $keytool"
		;;
        -*) 
        	echo "$0: unrecognized option: '$1'"
        	exit 1
        ;;
    esac
    shift
done

cer=$1
require "$cer" "1st arg must be the cer name"

ca=ca.$cer

# https://github.com/jsha/minica
#minica --domains $cer

echo "7. Para importar em uma keystore, é necessário criar o $cer p12:"
openssl pkcs12 -export -in $cer.crt -inkey $cer.key -chain -CAfile ca.$cer.crt -name "$cer" -out $cer.p12
echo

echo "8. Por fim importamos na keystore o p12"
# com senha
#keytool -importkeystore -deststorepass MY-KEYSTORE-PASS -destkeystore $cer.jks -srckeystore $cer.p12 -srcstoretype PKCS12
$keytool -importkeystore -destkeystore $cer.jks -srckeystore $cer.p12 -srcstoretype PKCS12

# test by listing certs:
#sudo keytool -list -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit | grep <nome certificado>

echo "Utilizaremos a keystore acima no jetty para ssl."
echo

echo "9. Instalação da CA no Linux"

sudo mkdir /usr/local/share/ca-certificates/
sudo cp ca.$cer.crt /usr/local/share/ca-certificates/ca.$cer.crt
sudo update-ca-certificates
echo

echo "Com isso, comandos como o curl já devem funcionar."
echo

echo "10. Instalando libnss3-tools"
sudo apt install libnss3-tools
echo

echo "11. Instalando no SO"
certfile="ca.$cer.pem"
certname="$cer"

for certDB in $(find ~/ -name "cert8.db")
do
    certdir=$(dirname ${certDB});
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d dbm:${certdir}
done

for certDB in $(find ~/ -name "cert9.db")
do
    certdir=$(dirname ${certDB});
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d sql:${certdir}
done

echo "done. return $?"