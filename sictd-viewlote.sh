#!/bin/bash

params="$1"
restrictions="$2"
join_type=${3:-"inner"}

case $join_type in
	"inner" )
		$hquery --sql "select $params from ec_pagina p, ec_imagemdepagina i, ec_lote l, ec_logimagem log, ec_imagemparaenvio envio where p.idlote=l.id and i.id=p.idimagem and log.idpagina=p.id and envio.idpagina=p.id and $restrictions;"
		;;
	"left" )
		$hquery --sql "select $params from ec_lote l left outer join ec_pagina p on l.id=p.idlote left outer join ec_imagemdepagina i on p.idimagem=i.id left outer join ec_imagemparaenvio envio on p.id=envio.idpagina left outer join ec_logimagem log on p.id=log.idpagina where $restrictions;"
		;;
esac


