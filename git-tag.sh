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
	echo "tag $v already exists, continue anyway? (ctrl+c to abort, any key to skip tag)"
	read anyKey
elif [[ "$v" == *SNAPSHOT* ]]; then
	echo "$v is snapshot, no tag will be created"
else
	echo "will create tag $v..."
	changelog="$3"
	if [ -f "$changelog" ]; then
		echo "found changelog $changelog"
		today=$(now.sh --date)
		echo "today: $today"

		new_change=$(grep -c "$v" "$changelog" || true)
		if [[ "$new_change" -eq 0 ]]; then
			echo "creating changelog entry..."
			changetype=$(echo "$msg" | cut -d' ' -f1)
			echo && echo >> $changelog
			echo "## [$v] - $today" >> $changelog
			echo "### ${changetype^}" >> $changelog
		fi

		echo "adding changelog message: $msg"
		echo "- @$USER - ${msg}" >> $changelog	

		echo "tagging as $v..."
		git commit -a -m "changelog"
	fi

	echo "tagging as $v..."
	git tag -a $v -m "$msg"

	echo "pushing tag $v"
	git push --tags
fi
