#!/bin/bash

verbose=false
debug=false
props='Specification-Title;Specification-Vendor'
report=report.txt

if [ ! -d "$1" ]; then
	echo "first argument must be an existing directory"
	exit 1
fi
source="$1"
shift

do_help() {
	echo "prints this message and exists"
	exit 0
}

while test $# -gt 0
do
    case "$1" in
		--verbose|-v) 
		    verbose=true
		;;
		--debug|-d)
			debug=true
		;;
		--help|-h)
			do_help
		;;
		--props)
			shift
			props="$1"
		;;
		--*)
		    echo "invalid option: '$1'"
		    exit 1
		;;
    esac
    shift
done

IFS=';' read -a array <<< "$props"
echo "Name;$props;Location" > "$report"

for f in $source/*.jar
do
	echo "$f"
	unzip -p $f META-INF/MANIFEST.MF > manifest.mf
	jarname=$(basename "$f")
	jardir=$(dirname "$f")
	str="$jarname"
	
	for prop in "${array[@]}"
	do
		prop_value=$(grep $prop manifest.mf | cut -d':' -f2)
		prop_value="${prop_value//[$'\t\r\n']}"
		prop_value=$(echo "$prop_value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
		
		if [ -n "$prop_value" ]; then
			echo "- $prop"
		fi
		
		str="${str};$prop_value"
	done

	str="${str};$jardir"
	echo "$str" >> "$report"
done

rm manifest.mf
echo "report generated in `pwd`/$report"
