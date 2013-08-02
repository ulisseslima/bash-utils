#!/bin/bash

verbose=false

server="smtp.gmail.com"
port=465
ssl=true
from="unspecified"
to=$from
user="unpecified"
passw="unspecified"
subject="unspecified"
message="unspecified"

do_help() {
	echo "Usage example:"
	echo "$0 --to email@domain.com"
}

debug() {
	if [ $verbose == "true" ]; then
		echo "$1"
	fi
}

while test $# -gt 0
do
    case "$1" in
        --verbose|-v|--debug)
        	verbose=true
        ;;
        --help|-h)
        	do_help
        	exit 0
        ;;
        --server|-s) 
        	shift
        	server=`echo "$1" | cut -d':' -f1`
        	port=`echo "$1" | cut -d':' -f2`
        ;;
        --ssl) 
        	shift
        	ssl=$1        	
        ;;
        --from|-f) 
        	shift
        	from=$1
        ;;
        --to|-t) 
        	shift
        	to=$1
        ;;
        --user|-u) 
        	shift
        	user=$1
        	if [ $from == 'unspecified' ]; then
        		from=$user
        	fi
        ;;      
        --password|--passw|-p) 
        	shift
        	passw=$1
        ;;          
        --subject) 
        	shift
        	subject=$1
        ;;        
        --message|-m) 
        	shift
        	message=$1
        ;;        
        --*) echo "bad option $1"
        	exit 1
	    ;;
    esac
    shift
done

if [ $passw == 'unspecified' ]; then
	read -s -p "Password for $user: " passw
fi

echo "sending mail to $to..."

java -jar \
-Dserver=$server \
-Dport=$port \
-Dssl=$ssl \
-Dfrom="$from" \
-Dto="$to" \
-Duser="$user" \
-Dpassword="$passw" \
-Dsubject="$subject" \
-Dmessage="$message" \
sendmail.jar
