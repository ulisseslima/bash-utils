#!/bin/sh

# Armazena um diretório relativo ao target, utilizando o nome do diretório atual [sem o nome base]
# e.g.: se eu executar esse script dentro de /home/ulisses/proj/conf/caixa, o diretório referência do script será /home/ulisses/sh/caixa


TARGET="/home/ulisses/sh"
ACTUAL=`pwd`

echo "$ACTUAL"

TARGET2=$TARGET/${ACTUAL##*/}

echo "$TARGET2"
