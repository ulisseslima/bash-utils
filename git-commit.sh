#!/bin/bash -e
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real log.sh)

REPO=$(git rev-parse --show-toplevel)

message="$1"
if [[ ! -n "$message" || "$message" == --tags ]]; then
	err "first arg must be commit message"
	exit 1
fi

if [[ "$message" == -r ]]; then
	if [[ -f "$(real smerge)" ]]; then
		# sublime merge
		smerge .
	else
		git diff
	fi

	exit 0
fi

if [ ! -f "$REPO/.gitignore" ]; then
	err ".gitignore not found. create and try again."
	exit 1
fi

shift
while test $# -gt 0
do
    case "$1" in
    --tags|-t)
    	shift
      	if [ -f "$1" ]; then
			version=$(pom.sh --version $1)
		elif [ -d "$1" ]; then
			version=$(pom.sh --version $1/pom.xml)
		elif [ -f ./pom.xml ]; then
			version=$(pom.sh --version ./pom.xml)
		elif [ -n "$1" ]; then
			version="$1"
		fi

		if [ ! -n "$version" ]; then
			err "when using --tags, be sure to have a pom.xml or specify version"
			exit 1
		fi

		# optional
		changelogf="$2"
		git-tag.sh "$version" "$message" "$changelogf"
    ;;
	--remote)
		shift
		remote="$1"
	;;
    -*) 
      echo "bad option '$1'"
    ;;
    esac
    shift
done

info "pulling..."
git pull

info "adding new files..."
git add .

info "commiting..."
git commit -a -m "$message"

info "pushing..."
git push $tags
