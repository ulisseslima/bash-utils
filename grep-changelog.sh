#!/bin/bash
# greps a changelog starting from a specific version
# changelog file must conform to the markdown default

grep_changelog() {
	changelog="$1"
	v=$2

	cat $changelog | sed -n -e "/$v/,\$p"
}

changelog="$1"
if [[ ! -f "$changelog" ]]; then
    echo "arg 1 must be a changelog file"
    exit 1
fi

version="$2"
if [[ -z "$version" ]]; then
    echo "arg 2 must be starting version number"
    exit 1
fi

grep_changelog "$changelog" "$version"