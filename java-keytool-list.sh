#!/bin/bash

jh="${1:-$JAVA_HOME}"
kt="$jh/bin/keytool"
cacerts="$jh/jre/lib/security/cacerts"

echo "java home: $jh"
echo "keytool: $jh"
echo "cacerts: $cacerts"

$kt -list -keystore $cacerts -storepass changeit
