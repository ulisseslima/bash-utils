#!/bin/bash

CONF=/etc/mysql/my.cnf
param=
value=

say() {
	echo "||| $0 - $1"
}

require() {
        switch='-s'
        if [[ "$1" == *'-'* ]]; then
            switch=$1
            shift
        fi

        case $switch in
          --string|-s)
                if [ ! -n "$1" ]; then
                    say "$2"
                    exit 1
                fi
          ;;
          --file|-f)
	            if [ ! -f "$1" ]; then
	                say "file not found: '$1'"
	                exit 1
            	fi
          ;;
          --dir|-d)
                if [ ! -d "$1" ]; then
                    say "directory not found: '$1'"
                    exit 1
                fi
          ;;
        esac
}

while test $# -gt 0
do
    case "$1" in
		--debug|-d)
			debug=true
		;;
		--help|-h)
			do_help
		;;
		--param|-p)
			shift
			param="$1"

			shift
			value="$1"
		;;
		--file|-f)
			shift
			CONF="$1"
		;;
		--*)
		    say "invalid option: '$1'"
		    exit 1
		;;
    esac
    shift
done

require -s "$param" 'the desired parameter to check must be specified with --param or -p'

prop=$(grep -w "$param" "$CONF")
gok=$?

if [[ $gok != 0 && -z "$value" ]]; then
	say "param $param is not defined. use --set <value> to create it"
elif [[ $gok != 0 && -n "$value" && "$value" != *-r* ]]; then
	say "param $param was not defined. setting it to $value"
	sudo sed -i "/\[mysqld\]/a $param = $value" "$CONF"
elif [[ $gok == 0 && -n "$value" ]]; then
	if [[ "$value" == *-r* ]]; then
		sudo sed -i "/$param/d" "$CONF"
		say "param removed: $param"
	else
		sudo sed -i "/$param/d" "$CONF"
		sudo sed -i "/\[mysqld\]/a $param = $value" "$CONF"
		say "from '$prop' to '$param = $value'"
	fi
elif [[ $gok == 0 && -z "$value" ]]; then
	say "$prop"
else
	say "unhandled case. var dump:"
	say "grep return: $gok"
	say "prop: $prop"
	say "param: $param"
	say "value: $value"
fi
