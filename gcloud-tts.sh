#!/bin/bash -e
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

trap 'catch $? $LINENO' EXIT
catch() {
  if [[ "$1" != "0" ]]; then
    echo "returned $1 at line $2"
  fi
}

verbose=false

text="$1"; shift
token=$(gcloud auth print-access-token)
project_id="$GOOG_TTS_PROJECT_ID"

lang_code=en-us
voice=en-US-Neural2-H
gender=FEMALE

require text
require token

hash=$(echo "$text" | md5sum | awk '{print $1}')
require hash

function mlog() {
	if [[ $verbose == true ]]; then 
    >&2 echo "$@"
  fi
}

# returns: 1 == true
function is_mp3() {
  local f="$1"

  mlog "checking if $f is mp3..."

  if [[ ! -f "$f" ]]; then
    echo 0
    return 0
  fi
  
  file $f | grep -c 'MPEG ADTS, layer III' || true
}

while test $# -gt 0
do
    case "$1" in
    --verbose|-v)
      verbose=true
    ;;
    --lang-code|-c)
      shift
      lang_code="$1"
    ;;
    --voice)
      shift
      voice="$1"
    ;;
    --gender|-g)
      shift
      gender="${1^^}"
    ;;
    --project)
      shift
      project_id="${1}"
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

require project_id

cached=/tmp/$ME/$project_id/$hash
mkdir -p $cached
require -d cached

outf=$cached/$gender-$voice.mp3
mlog "project: $project_id"
mlog "token: $token"
mlog "hash: $hash"

if [[ $(is_mp3 "$outf") != 1 ]]; then
  mlog "requesting tts..."

  jsonf=$cached/$gender-$voice.json
	curl -H "X-Goog-User-Project: $project_id" -H "Authorization: Bearer $token" -H "Content-Type: application/json; charset=utf-8" --data "{
  	 'input':{
    	  'text':'${text}'
  	 },
  	 'voice':{
    	  'languageCode':'${lang_code}',
    	  'name':'${voice}',
    	  'ssmlGender':'${gender}'
  	 },
  	 'audioConfig':{
    	  'audioEncoding':'MP3'
  	 }
	}" "https://texttospeech.googleapis.com/v1/text:synthesize" > $jsonf

  cat $jsonf | jq -r .audioContent | base64 -d > $outf
else
  mlog "returning from cache..."
fi

file $outf
play $outf
