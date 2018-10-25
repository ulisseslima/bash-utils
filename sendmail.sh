#!/bin/bash

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"

verbose=false

html=false
server="smtp.gmail.com"
port=465
ssl=true
tls=false
from=$MAIL_USERNAME
to=$from
user=$MAIL_USERNAME
passw=$MAIL_PASSW
subject="unspecified"
message="unspecified"
attach=""

do_help() {
	echo "Usage example:"
	echo "$0 --to email@domain.com"
}

say() {
        echo "||| $0 - $1"
}

debug() {
	if [ $verbose == "true" ]; then
		say "$1"
	fi
}

while test $# -gt 0
do
    case "$1" in
	-v|-h)
		echo "$0 v2.1"
		exit 0
	;;
        --verbose|--debug)
        	verbose=true
        ;;
        --help|-h)
        	do_help
        	exit 0
        ;;
        --html)
        	shift
        	html=$1
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
	--tls)
		shift
		tls=$1
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
	--attach|-a)
		shift
		attach="$1"
	;;
        --*)
		say "bad option $1"
        	exit 1
	;;
    esac
    shift
done

if [ "$passw" == 'unspecified' ]; then
	read -s -p "$0 email password for $user: " passw
fi

say "sending mail to $to..."
say "attachments: $attach"
if [ $verbose == true ]; then
	say "server $server"
	say "port $port"
	say "ssl $ssl"
	say "tls $tls"
	say "user $user"
	say "from $from"
	say "message $message"
fi

echo "$MYDIR"

if [[ $(grep -c MultiPartEmail "$MYDIR/sendmail.jar") < 1 ]]; then
	echo "jar does not have all necessary dependencies, please create it again"
	exit 1
fi

java -jar \
-Dhtml=$html \
-Dserver=$server \
-Dport=$port \
-Dssl=$ssl \
-Dtls=$tls \
-Dfrom="$from" \
-Dto="$to" \
-Duser="$user" \
-Dpassword="$passw" \
-Dsubject="$subject" \
-Dmessage="$message" \
-Dattach="$attach" \
$MYDIR/sendmail.jar

