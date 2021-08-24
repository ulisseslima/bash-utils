#!/bin/bash -e
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real log.sh)

while test $# -gt 0
do
	case "$1" in
		-f|--readme|--changelog)
			shift
			changelog="$1"
		;;
		-v|--version)
			shift
			version="$1"
		;;
		*) 
			echo "unrecognized option: $1"
			exit 1
		;;
	esac
	shift
done

if [[ ! -f "$changelog" ]]; then
	info "arg 1 must be the changelog file. not a file: '$changelog'"
	exit 1
fi

if [[ -z "$version" ]]; then
	info "arg 2 must be the version"
	exit 1
fi

info "last 5 tags:"
git tag | tail -5

changes=$(grep-changelog.sh "$changelog" $version)

if [[ $(git tag -l $version) ]]; then
	err "tag '$version' already exists, continue anyway? (ctrl+c to abort, any key to skip tag)"
	read anyKey
elif [[ "$version" == *SNAPSHOT* ]]; then
	info "$version is snapshot, no tag will be created"
else
	info "will create tag $version ..."
	info "related issues: "
	header=$(echo "$changes" | grep ':' | cut -d'-' -f3 | cut -d':' -f1 | tr -d ' ' | tr '\n' ' ')

	info "tagging as $version ..."
	git tag -a $version -m "$header
	
	$changes"

	info "pushing tag $version"
	git push --tags
fi
