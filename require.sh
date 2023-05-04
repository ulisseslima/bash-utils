#!/bin/bash
# tests a if a required variable name is not empty, just source this script into yours

function llog() {
	>&2 echo "$@"
}

require() {
	switch='-s'
	if [[ "$1" == *'-'* ]]; then
		switch=$1
		shift

		if [[ $switch == "--in" ]]; then
			collection="$1"
			shift
		fi
	fi

	local keyname="$1"
	local value="${!keyname}"
	local info="$2"

	case $switch in
		--string|-s)
			if [[ -z "$value" ]]; then
				llog "required variable has no value: $keyname ($info)"
				exit 1
			elif [[ "$value" == null ]]; then
				llog "required variable has no value: $keyname ($info)"
				exit 1
			elif [[ "$value" == undefined ]]; then
				llog "required variable has no value: $keyname ($info)"
				exit 1
			fi
		;;
		--number|-n)
			if [[ -z "$value" ]]; then
				llog "required variable has no value: $keyname ($info)"
				exit 1
			elif [[ $(nan.sh "$value") == true ]]; then
				llog "not a number: $keyname = '$value'"
				exit 1
			fi
		;;
		--nan|-N)
			if [[ -z "$value" ]]; then
				llog "required variable has no value: $keyname ($info)"
				exit 1
			elif [[ $(nan.sh "$value") == false ]]; then
				llog "should not be a number: $keyname = '$value'"
				exit 1
			fi
		;;
		--math-expression|-nx)
			local no_expression=$(echo "$value" | sed -e 's:[*/+-\(\)]::g')
			if [[ -z "$value" ]]; then
				llog "required variable has no value: $keyname ($info)"
				exit 1
			elif [[ $(nan.sh "$no_expression") == true ]]; then
				llog "not a valid math expression: $keyname = '$value'"
				exit 1
			fi
		;;
		# e.g.: require --in 'VAL_A VAL_B' var_a
		# var_a's value should contain one of the values specified
		--in)
			# FIXME @unsafe can give false positives.
			if [[ -z "$value" || "$collection" != *"$value"* ]]; then
				llog "$keyname: not one of: '$collection'"
				exit 1
			fi
		;;
		--file|-f)
			if [[ ! -f "$value" ]]; then
				llog "a required file was not found: '$value' (varname: $keyname) - $info"
				exit 2
			fi

			if [[ ! -s "$value" ]]; then
				llog "file must be non-empty: '$value' (varname: $keyname) - $info"
				exit 2
			fi

			if [[ "$info" == -* ]]; then
				format=$(echo "$info" | cut -d'-' -f2)
				ff=$(file "$value")
				if [[ "$ff" != *"$format"* ]]; then
					llog "file must be of type '$format' but is '$ff'"
					exit 3
				fi
			fi
		;;
		--dir|-d)
			if [ ! -d "$value" ]; then
				llog "a required dir was not found: '$value' (varname: $keyname) - $info"
				exit 3
			fi
		;;
		# e.g.: require --any var_a var_b [var_c ...]
                # at least one of the vars has to be set
	        --any)
			local vars=
			local ok=false
			while test $# -gt 0
			do
				local key="$1"
				local val="${!key}"

				vars="$vars, $key"

				if [[ -n "$val" ]]; then
					ok=true
					break
				fi

				shift
			done

			if [[ $ok == false ]]; then
				llog "at least one of the subsequent variables should be set: $vars"
				exit 4
			fi
		;;
		# e.g.: require --one var_a var_b [var_c ...]
		# if none or more than one of those is set, it fails.
		--one)
			local vars=
			local one=
			while test $# -gt 0
			do
				local key="$1"
				local val="${!key}"

				vars="$vars, $key"

				if [[ "$one" == set && -n "$val" ]]; then
					llog "only one of the subsequent variables should be set: $vars"
					exit 5
				fi

				if [[ -n "$val" ]]; then
					one=set
				fi

				shift
			done

			if [[ -z "$one" ]]; then
				llog "one of these variables should be set: $vars"
				exit 5
			fi
		;;
	esac
}
