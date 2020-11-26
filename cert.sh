#!/bin/bash

nargs=$#

if [ $nargs == 0 ]; then
  do_help
  exit 0
fi

cert_file=""
jhome="$JAVA_HOME"
jrehome="$JAVA_HOME/jre"
op=

do_help() {
    echo "certificate operations."
    echo ""
    echo "to install a certificate:"
    echo "$0 --install alias --java /java/home"
    echo "if '--java' is not specified, $JAVA_HOME is used"
    echo "- installs to both jre and jdk, if present"
    echo "- 'alias' must be a file"
}

do_import() {
    alias_="$1"
    f_="$2"
    java_="$3"

    cmd="keytool -import -noprompt -trustcacerts -alias $alias_ -file $f_ -keystore $java_/lib/security/cacerts -storepass changeit"
    echo "$cmd"
    $cmd
}

do_install() {
	do_import $cert_alias "$cert_file" "$jhome"
    if [ -f "$jrehome/lib/security/cacerts" ]; then
        do_import $cert_alias "$cert_file" "$jrehome"
    fi
}

do_test() {
    alias_="$1"
    java_="$2"

    echo "testando alias $alias_ em $java_"
    keytool -list -keystore $java_/lib/security/cacerts -storepass changeit | grep $alias_
}

while test $# -gt 0
do
    case "$1" in
        --help)
            do_help
        ;;
        --install|-i)
            shift
            cert_file="$1"
            op="install"
        ;;
        --remove|-r)
            shift
        	cert_file="$1"
            op="remove"
        ;;
        --gen|-g)
            shift
            op="generate"
        ;;
        --java|-j)
            shift
            jhome="$1"
            jrehome="$jhome/jre"
        ;;
        --test)
            shift
            alias_="$1"
            java_="$2"

            do_test "$alias_" "$java_"
            echo "---"
            if [ -d "$java_/jre" ]; then
                do_test "$alias_" "$java_/jre"
            fi

            exit 0
        ;;
        --*)
            echo "bad option $1"
        ;;
        *)
            echo "Usage: $0 {install|remove}"
        ;;
    esac
    shift
done

cert_alias=$(basename "$cert_file" | rev | cut -d'.' -f2- | rev)
if [ ! -n "$cert_alias" ]; then
    echo "unable to derive alias from file $cert_file"
    exit 1
fi
echo "alias: $cert_alias"
echo "java home: $jhome"
echo "jre home: $jrehome"

case "$op" in
    install)
        do_install
    ;;
    *)
        echo "Operation not implemented: $op"
    ;;
esac
