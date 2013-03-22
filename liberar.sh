#!/bin/sh

set -e

nargs=$#

if [ $nargs == 0 ]; then
  echo "no args were provided"
else
  echo "$nargs provided"
fi

do_start() {
	echo "start!"
}

do_stop() {
	echo "stop!"
}

case "$1" in
  start)
	do_start
	;;
  stop)
	do_stop
	;;
  restart|force-reload)
	do_stop
	do_start
	;;
  *)
	echo "Usage: $0 {start|stop|restart|force-reload}"
	exit 3
	;;
esac

# endereço do servidor desejado
SAMBA_HOST=samba #192.168.0.6
# nome do share onde se deseja iniciar a navegação
SAMBA_SHARE=Teste
# Usuário do samba
USER=ulisseslima
# Senha do usuário samba
PASSW=6des7@murah
# Workgroup (Murah ou Safira)
WORKGROUP=Murah
# Local onde reside o template de diretório de liberação
TEMPLATE_DIR=/home/ulisses/proj/deploy
# Padrão de nomeação do diretório de liberação
DEPLOY_DIR_PATTERN=yyyymmdd-v$
# Data atual
DEPLOY_DATE=`date +'%Y%m%d'`
# LPT
LPT_DATE=`date +'%Y-%m-%d'`
LPT_DOC_NAME=LPT_ConteXpress_Caixa-Server_${LPT_DATE}_v1.doc
LPT_DUMMY_NAME=LPT_ConteXpress_Caixa-Server_yyyy-mm-dd_v1.doc

# Versão do projeto conforme o pom em $SERVER_DIR
PROJECT_VERSION=`xml sel -N x=http://maven.apache.org/POM/4.0.0 -t -v "/x:project/x:version" "$SERVER_DIR"/pom.xml`

# Prefixo para versão de tags
TAG_PREFIX=P354_

# Nome do arquivo tar onde será armazenado o diretório de liberação para transmissão pela rede
TAR_LIBERACAO=$DEPLOY_DATE-v$PROJECT_VERSION.tar.gz

# Diretório de liberação que será criado
DIR_LIBERACAO_ATUAL=$TEMPLATE_DIR/$DEPLOY_DATE-v$PROJECT_VERSION

# Gera tag do projeto no diretório atual utilizando o prefixo e a versão do pom (substituindo ponto por underscore)
cvs_tag()
{
	cd "$1"
	echo "Gerando tag do projeto em `pwd`"
	
	cvs login
	cvs tag -R ${TAG_PREFIX}${PROJECT_VERSION//'.'/'_'}
}

# Verifica se o pom contém snapshot
verify_version()
{
	echo "Verificando Versão do projeto..."	

	if [[ $PROJECT_VERSION == *SNAPSHOT* ]]
	then
	  echo "Versão incorreta (SNAPSHOT)";
	  exit 1
	fi
	echo "Criando deploy da versão $PROJECT_VERSION..."
}

# Executa as operações do maven necessárias para o deploy da aplicação
# Gera tags
run_mvn()
{
	cd "$TRATDOC_DIR"
	mvn clean install clean	
	
	cd "$SERVER_DIR"
	mvn clean package
}

# Cria o diretório que será enviado para o servidor.
mkdir_deploy()
{
	echo "Criando diretório de liberação..."
	cp -r "$TEMPLATE_DIR/$DEPLOY_DIR_PATTERN" "$DIR_LIBERACAO_ATUAL"
	cd target
	mv contexpress-server.war "$DIR_LIBERACAO_ATUAL"/Server/
	cd "$DIR_LIBERACAO_ATUAL"/LPT
	mv "$LPT_DUMMY_NAME" "$LPT_DOC_NAME"
	
	echo "Diretório de liberação criado."
}

zip_deployment()
{
	cd "$TEMPLATE_DIR"
	echo "Compactando diretório de liberação para transmissão via rede em `pwd`..."
	tar -vcf "$TAR_LIBERACAO" "$DEPLOY_DATE-v$PROJECT_VERSION"
	
	echo "Tar criado."
}

# Envia o tar gerado para o samba, descompacta e remove o tar.
upload()
{
	echo "Movendo para o servidor..."
smbclient //$SAMBA_HOST/$SAMBA_SHARE/ $PASSW -W $WORKGROUP -U $USER << EOC
cd "$DEPLOY_DIR"
put "$TAR_LIBERACAO"
tar x $TAR_LIBERACAO
rm "$TAR_LIBERACAO"
EOC
	rm "$TAR_LIBERACAO"
}

verify_version
run_mvn
mkdir_deploy
zip_deployment
upload
cvs_tag $TRATDOC_DIR
cvs_tag $SERVER_DIR

echo "Concluído."
