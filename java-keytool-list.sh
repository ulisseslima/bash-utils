#!/bin/bash

source $(real require.sh)

jh="${1:-$JAVA_HOME}"
kt="$jh/bin/keytool"
cacerts="$jh/jre/lib/security/cacerts"

require -d jh JAVA_HOME
require -f kt "keytool executable not found at '$kt'"
require -f cacerts "cacerts file not found at '$cacerts'"

echo "java home: $jh"
echo "keytool: $kt"
echo "cacerts: $cacerts"

# determine whether we need to run keytool under sudo (if we can't write to the keystore)
SUDO=""
if [ -e "$cacerts" ]; then
	if [ ! -w "$cacerts" ]; then
		SUDO="sudo"
	fi
else
	parentdir="$(dirname "$cacerts")"
	if [ ! -w "$parentdir" ]; then
		SUDO="sudo"
	fi
fi

if [ -n "$SUDO" ]; then
	if ! command -v sudo >/dev/null 2>&1; then
		echo "No write permission for $cacerts and sudo is not available; please run this script as a user who can write $cacerts or install sudo"
		exit 1
	fi
	echo "# will use sudo for keystore operations"
fi

# helper to run keytool, optionally under sudo
run_kt() {
	if [ -n "$SUDO" ]; then
		"$SUDO" "$kt" "$@"
	else
		"$kt" "$@"
	fi
}

run_kt -list -keystore "$cacerts" -storepass changeit
