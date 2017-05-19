#!/bin/bash

cd `dirname $0`

generate_cpf() {
	javac Cpf.java
	java Cpf
}

generate_cnpj() {
	javac Cnpj.java
	java Cnpj
}

while test $# -gt 0
do
	case "$1" in
		--cpf)
			generate_cpf
		;;
		--cnpj)
			generate_cnpj
		;;
		--*)
			echo "opção não reconhecida: $1"
			exit 1
		;;
	esac
	shift
done

exit 0

while test $# -gt 0
do
	case "$1" in
		--cpf)
			generate_cpf
		;;
		--cnpj)
			generate_cnpj
		;;
		--*)
			echo "unrecognized option: $1"
			exit 1
		;;
	esac
	shift
done

exit 0
