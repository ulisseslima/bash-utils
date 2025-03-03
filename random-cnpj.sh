#!/bin/bash
# gera um cnpj

source /etc/profile

response=$(curl -s https://www.dvlcube.com/generate/cnpj -H "Authorization: Bearer $RAPID_TOKEN")

cnpj=$(echo "$response" | jq -r .cnpj)
echo $cnpj
echo $cnpj | ctrlc.sh
