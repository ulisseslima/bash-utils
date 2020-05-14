#!/bin/bash

function safe_name() {
    name=$(echo "$1" | iconv -f utf8 -t ascii//TRANSLIT)
    name=$(echo ${name,,})
    echo ${name// /-}
}

safe_name "$1"
