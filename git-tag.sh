#!/bin/bash -e

v="$1"
if [ ! -n "$v" ]; then
	echo first arg must be the tag name
	exit 1
fi

msg="$2"
if [ ! -n "$msg" ]; then
	echo second arg must be the tag message
	exit 1
fi

echo "current tags:"
git tag

if [[ "$(git tag | grep -c $v)" -gt 0 ]]; then
	echo "tag $v already exists, skipping..."
else
	changelog="$3"
	if [ -f "$changelog" ]; then
		today=$(now.sh --date)

		new_change=$(grep -c "$v" "$changelog")
		if [[ "$new_change" -eq 0 ]]; then
			changetype=$(echo "$msg" | cut -d' ' -f1)
			echo && echo >> $changelog
			echo "## [$v] - $today" >> $changelog
			echo "### ${changetype^}" >> $changelog
		fi

		echo "- @$USER - ${msg}" >> $changelog	
	fi

	echo "tagging as $v..."
	git tag -a $v -m "$msg"

	echo "pushing tag $v"
	git push --tags
fi
