#!/bin/bash
# https://www.sslshopper.com/ssl-checker.html#hostname=https://host.com
site="$1"
if [[ -z "$site" ]]; then
	echo "arg1 must be site:port"
	exit 1
fi

if [[ "$site" != *:* ]]; then
	site="${site}:443"
fi

echo "checking certificate from $site ..."
echo | openssl s_client $site 2>/dev/null | grep Verification
