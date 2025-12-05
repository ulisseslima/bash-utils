#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 PARENT"
    echo "Finds all Maven modules (by searching pom.xml) that declare the given parent."
    echo
    echo "PARENT formats accepted:" 
    echo "  artifactId                 match parent by artifactId only"
    echo "  groupId:artifactId         match parent by group and artifact"
    echo
    echo "Examples:"
    echo "  $0 my-parent-artifact"
    echo "  $0 com.example:my-parent"
}

if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

PARENT="$1"

if ! command -v xmlstarlet >/dev/null 2>&1; then
    echo "Error: xmlstarlet is required but not installed." >&2
    echo "Install it (e.g. on Debian/Ubuntu: sudo apt install xmlstarlet)" >&2
    exit 2
fi

NS="-N x=http://maven.apache.org/POM/4.0.0"

if [[ "$PARENT" == *":"* ]]; then
    GROUP="${PARENT%%:*}"
    ARTIFACT="${PARENT#*:}"
    MATCH_GROUP=true
else
    ARTIFACT="$PARENT"
    MATCH_GROUP=false
fi

find . -name pom.xml -print0 | while IFS= read -r -d '' pom; do
    # retrieve parent artifactId (skip if none)
    parent_artifact=$(xmlstarlet sel $NS -t -v "normalize-space(/x:project/x:parent/x:artifactId)" -n "$pom" 2>/dev/null || true)
    if [ -z "$parent_artifact" ]; then
        continue
    fi

    if [ "$MATCH_GROUP" = true ]; then
        parent_group=$(xmlstarlet sel $NS -t -v "normalize-space(/x:project/x:parent/x:groupId)" -n "$pom" 2>/dev/null || true)
        if [ "$parent_group" != "$GROUP" ] || [ "$parent_artifact" != "$ARTIFACT" ]; then
            continue
        fi
    else
        if [ "$parent_artifact" != "$ARTIFACT" ]; then
            continue
        fi
    fi

    module_artifact=$(xmlstarlet sel $NS -t -v "normalize-space(/x:project/x:artifactId)" -n "$pom" 2>/dev/null || true)
    parent_version=$(xmlstarlet sel $NS -t -v "normalize-space(/x:project/x:parent/x:version)" -n "$pom" 2>/dev/null || true)

    # print relative module path, module artifactId and the parent coordinates found
    printf "%s : %s (parent: %s:%s:%s)\n" "$(dirname "$pom")" "${module_artifact:-<unknown>}" "${parent_group:-<unknown>}" "$parent_artifact" "${parent_version:-<unknown>}"
done
