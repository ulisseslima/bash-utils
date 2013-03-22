#!/bin/bash

set -e

DB_DIR=`pwd`

start() {
	if [ ! -f "$DB_DIR/db/unidadeCaptura.script" ]; then
		    echo "Script não encontrado em $DB_DIR/db/unidadeCaptura.script"
		    exit 1
	fi      
	java -cp "$HSQLDB_JAR" org.hsqldb.Server -database.0 file:"$DB_DIR"/db/unidadeCaptura -dbname.0 unidadeCaptura > /dev/null &
	$hquery --sql "select count(id) from ec_imagemparaenvio;"
	$hquery --sql "select count(idp.id), 'lq' from ec_imagemdepagina as idp, ec_pagina as p, ec_lote as l where (enviadobaixaqualidade=false) and p.idimagem=idp.id and p.idlote=l.id and (l.status != 'cancelado' 
	and l.status != 'novo') 
	union select count(idp.id), 'hq' from ec_imagemdepagina as idp, ec_pagina as p, ec_lote as l where (enviadoaltaqualidade=false) and p.idimagem=idp.id and p.idlote=l.id and (l.status != 'cancelado' and l.status != 
	'novo');"
	$hquery --sql "select max(data), 'erro envio' from ec_logimagem where acao like '%Erro no envio%' union select max(data), 'captura' from ec_logimagem where acao like '%Captura%' union select max(data), 'envio' from ec_logimagem where acao like 'Envio%';"
}

stop() {
	echo "Stopping hsqldb in $DB_DIR..."
	$hquery --sql "SHUTDOWN COMPACT;"
	sleep 3	
}

if [ "$1" == "start" ]; then
	echo "Starting $DB_DIR..."
	start "$DB_DIR"
fi

if [ "$1" == "stop" ]; then
	stop
fi

if [ $# == 0 ]; then
	echo "Como usar:"
	echo "A partir do diretório de um backup de uma base (o diretório acima do diretório 'db'), execute este script passando:"
	echo "start		- para iniciar"
	echo "stop		- para parar o banco"
fi
