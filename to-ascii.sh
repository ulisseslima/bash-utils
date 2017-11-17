#!/bin/bash

echo "$1" | iconv -f utf8 -t ascii//TRANSLIT
