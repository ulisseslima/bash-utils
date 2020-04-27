#!/bin/bash -e
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real log.sh)

message="$1"
if [[ ! -n "$message" || "$message" == --tags ]]; then
	err "first arg must be commit message"
	exit 1
fi

if [ ! -f ./.gitignore ]; then
	err ".gitignore not found. create and try again."
	exit 1
fi

shift
tags="$1"
if [[ "$tags" == --tags ]]; then
	if [ -f "$2" ]; then
		version=$(pom.sh --version $2)
	elif [ -d "$2" ]; then
		version=$(pom.sh --version $2/pom.xml)
	elif [ -f ./pom.xml ]; then
		version=$(pom.sh --version ./pom.xml)
	elif [ -n "$2" ]; then
		version="$2"
	fi

	if [ ! -n "$version" ]; then
		err "when using --tags, be sure to have a pom.xml or specify version"
		exit 1
	fi

	git-tag.sh "$version" "$message"
fi

info "pulling..."
git pull

info "adding new files..."
git add .

info "commiting..."
git commit -a -m "$message"

info "pushing..."
git push $tags