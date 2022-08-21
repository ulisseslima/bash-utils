#!/bin/bash

logf="$1"

function info() {
	>&2 echo "$@"
}

info "size before: $(du -sh $logf)"
cat "$logf" | grep -v 'at org' > "$logf.1"
cat "$logf.1" | grep -v 'at sun' > "$logf.2"
cat "$logf.2" | grep -v 'at java' > "$logf.3"

info "size after: $(du -sh $logf.4)"
readlink -f "$logf.4"
