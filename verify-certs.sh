#!/bin/bash -e
# https://www.nmmapper.com/sys/tools/subdomainfinder/
# https://www.geocerts.com/ssl-checker

domains="$1"
if [[ ! -f "$domains" ]]; then
	echo "arg 1 must be a file containing domains to check for certification errors"
	exit 1
fi

verify() {
	domain="$1"
	echo "4 - verifying domain $domain"

	openssl s_client "$domain:443" 2>&1<<EOT
		bla
		bla
EOT
}

domain_ok() {
	domain="$1"
	#echo "3 - checking domain $domain"
	verify "$domain" | grep -ci 'verification error'
	#echo "5 - checked domain $domain"
}

scanned=0
while read domain
do
	echo -ne "\r - scanning [$scanned] $domain ------------------------------------------------------------------"
	# echo "1 - checking domain $domain"
	ok=$(domain_ok "$domain" || true)
	if [[ "$ok" == 1 ]]; then
		echo && echo "verification error for: $domain"
	fi
	# echo "2 - checked domain $domain"
	
	scanned=$((scanned+1))
done < $domains

echo && echo "scan finished"