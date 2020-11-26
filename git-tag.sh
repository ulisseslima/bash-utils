#!/bin/bash -e
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real log.sh)

v="$1"
if [ ! -n "$v" ]; then
	info first arg must be the tag ID
	exit 1
fi

msg="$2"
if [ ! -n "$msg" ]; then
	info second arg must be the tag message
	exit 1
fi

info "last 5 tags:"
git tag | tail -5

if [[ $(git tag -l $v) ]]; then
	err "tag '$v' already exists, continue anyway? (ctrl+c to abort, any key to skip tag)"
	read anyKey
elif [[ "$v" == *SNAPSHOT* ]]; then
	info "$v is snapshot, no tag will be created"
else
	info "will create tag $v..."

	# readme
	changelog="${3:-changelog.md}"
	if [ -f "$changelog" ]; then
		skip=$(grep -c "$msg" $changelog || true)

		info "found changelog $changelog"
		today=$(now.sh --date)
		info "today: $today"

		if [[ $skip -eq 0 ]]; then
			new_change=$(grep -c "$v" "$changelog" || true)
			if [[ "$new_change" -eq 0 ]]; then
				info "creating changelog entry..."
				changetype=$(echo "$msg" | cut -d' ' -f1)
				echo && echo >> $changelog
				echo "## [$v] - $today" >> $changelog
				echo "### ${changetype^}" >> $changelog
			fi

			info "adding changelog message: $msg"
			echo "- @$USER - ${msg}" >> $changelog
		fi

		info "tagging as $v..."
		git commit -a -m "changelog"
	fi

	info "tagging as $v..."
	git tag -a $v -m "$msg"

	info "pushing tag $v"
	git push --tags
fi
