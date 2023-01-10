#!/bin/bash
# https://rapidapi.com/capitalize-my-title-cmt/api/capitalize-my-title/
# https://capitalizemytitle.com/
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

parse() {
    outf="$1"
    parsed=$(cat "$outf" | jq -r .data.output | tr -d '"')
    
    if [[ -z "$parsed" ]]; then
        >&2 echo "couldn't parse: $(cat $outf)"
        return 1
    fi
    echo "$parsed"
}

capitalize() {
    local title="$1"

    curl -s --request GET \
    --url "https://capitalize-my-title.p.rapidapi.com/title/apa/title-case/$title" \
    --header 'X-RapidAPI-Host: capitalize-my-title.p.rapidapi.com' \
    --header "X-RapidAPI-Key: $CMT_API_KEY"
}

cache=/tmp/$ME
mkdir -p $cache

title="$1"

require CMT_API_KEY "Capitalize my title API key"
require title

cachef="$cache/${title,,}"

if [[ -f "$cachef" ]]; then
    >&2 echo "from cache:"
    parse "$cachef"
    exit 0
fi

title=$(capitalize "$title")
while [[ "$title" == *'You have exceeded the rate limit per second for your plan'* ]]
do
    >&2 echo "`date` - ERR: $title"
    sleep 1
    title=$(capitalize "$title")
done

if [[ -z "$title" ]]; then
    >&2 echo "empty response"
    exit 1
fi

echo "$title" > "$cachef"
parse "$cachef"
