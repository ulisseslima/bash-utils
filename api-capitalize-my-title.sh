#!/bin/bash
# https://rapidapi.com/capitalize-my-title-cmt/api/capitalize-my-title/
# https://capitalizemytitle.com/
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

parse() {
    outf="$1"
    cat "$outf" | jq -r .data.output | tr -d '"'
}

capitalize() {
    local title="$1"

    curl --request GET \
    --url "https://capitalize-my-title.p.rapidapi.com/title/ap/title-case/$title" \
    --header 'X-RapidAPI-Host: capitalize-my-title.p.rapidapi.com' \
    --header "X-RapidAPI-Key: $CMT_API_KEY"
}

require CMT_API_KEY "Capitalize my title API key"

cache=/tmp/$ME
mkdir -p $cache

title="$1"
cachef="$cache/${title,,}"

if [[ -f "$cachef" ]]; then
    >&2 echo "from cache:"
    parse "$cachef"
    exit 0
fi

title=$(capitalize "$title")
echo "$title" > "$cachef"
parse "$cachef"
