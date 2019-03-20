#!/bin/bash

require() {
    switch='-s'
    if [[ "$1" == *'-'* ]]; then
        switch=$1
        shift
    fi

    case $switch in
      --string|-s)
        if [ ! -n "$1" ]; then
            log "$2"
            exit 1
        fi
      ;;
      --file|-f)
        if [ ! -f "$1" ]; then
            log "Arquivo não encontrado: '$1'"
            exit 1
        fi
      ;;
      --dir|-d)
        if [ ! -d "$1" ]; then
            log "Diretório não encontrado: '$1'"
            exit 1
        fi
      ;;
    esac
}

now=$(date +'%Y-%m-%d_%H-%M-%S')
fname="pdf-${now}"

require -f $(which enscript)
require -f $(which ps2pdf)

enscript -p "${fname}.ps" /dev/stdin
ps2pdf "${fname}.ps"

rm "${fname}.ps"

out="$1"
if [ -n "$out" ]; then
	echo "moving ${fname}.pdf to $out"
	mv "${fname}.pdf" "$out"
fi
