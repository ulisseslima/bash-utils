#!/bin/bash

function safe_name() {
    # remove non ascii:
    name=$(echo "$1" | iconv -f utf8 -t ascii//TRANSLIT)
    limit=${2:-100}

    # to lower case:
    name=$(echo ${name,,})
    # replace spaces for "-", then remove anything that's non alphanumeric
    safen=$(echo ${name// /-} | sed 's/[^a-z0-9-]//g')
    echo "${safen:0:$limit}"
}

safe_name "$1"
