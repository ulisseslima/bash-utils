#!/bin/bash
# https://github.com/ulisseslima/dvl-mail
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"

do_help() {
	echo "Usage example:"
	echo "$0 --to email@domain.com"
}

say() {
        echo "||| $0 - $1"
}

debug() {
	if [ "$verbose" == "true" ]; then
		say "$1"
	fi
}

source /etc/profile
if [[ "$1" == '--config' ]]; then
	shift; config="$1"
	if [ ! -f "$config" ]; then
        	say "not a file: 'config'"
        	exit 1
        fi

        say "loading configs from external file: $config"
        say "$(cat $config)"
        source $config
	shift
fi

verbose=false
html=false
server="smtp.gmail.com"
port=${MAIL_PORT:-465}
ssl=${MAIL_SSL:-true}
tls=${MAIL_TLS:-false}
from="$MAIL_USERNAME"
to=$from
user="$MAIL_USERNAME"
passw="$MAIL_PASSW"
subject="unspecified"
message="unspecified"
attach=""

while test $# -gt 0
do
    case "$1" in
		--version)
			echo "$0 v2.2"
			exit 0
		;;
        --verbose|--debug|-v)
        	verbose=true
        ;;
        --help|-h)
        	do_help
        	exit 0
        ;;
        --config)
			say "--config arg must be specified as first arg"
			exit 1
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
        	passw="$1"
        ;;
        --subject)
        	shift
        	subject="$1"
        ;;
        --message|-m)
        	shift
        	message="$1"
			if [[ -f "$message" ]]; then
				message=$(cat "$message")
			fi
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

if [ $verbose == true ]; then
	say "server '$server'"
	say "port '$port'"
	say "ssl '$ssl'"
	say "tls '$tls'"
	say "user '$user'"
	say "from '$from'"
	say "message '$message'"
	say "password '$passw'"
fi

echo "$MYDIR"

if [[ $(grep -c MultiPartEmail "$MYDIR/sendmail.jar") < 1 ]]; then
	echo "jar does not have all necessary dependencies, please create it again"
	exit 1
fi

if [[ $html == true ]]; then
        if [ -n "$MAIL_SIG" ]; then
                echo "attaching signature..."
                message="$message<p>$(cat $MAIL_SIG)"
        else
                echo "MAIL_SIG is undefined, no signature will be included"
        fi
fi

if [ "$passw" == 'unspecified' ]; then
	read -s -p "$0 email password for $user: " passw
fi

if [[ ! -n "$to" ]]; then
	say "no recipients specified"
	exit 1
fi
if [[ ! -n "$user" ]]; then
	say "no sender user specified"
	exit 1
fi

say "sending mail to $to..."
if [ -n "$attach" ]; then
        say "attachments: $attach"
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
-Ddebug="$verbose" \
$MYDIR/sendmail.jar

