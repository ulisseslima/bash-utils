#!/bin/bash

if [ ! -f "$1" ]; then
	echo "first argument must be an existing p7s file"
fi

openssl pkcs7 -in "$1" -inform DER -print_certs
