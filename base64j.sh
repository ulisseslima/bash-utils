#!/bin/bash
# multiline b64 json

f="$1"

ftmp=/tmp/b64
echo "[" > $ftmp
cat "$f" | base64 | inline-java.sh 'println("\""+stdin+"\",");' >> $ftmp
echo "]" >> $ftmp

cat $ftmp
