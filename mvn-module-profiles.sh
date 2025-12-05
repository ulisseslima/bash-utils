#!/bin/bash
# receives a module and shows its profiles

set -euo pipefail

usage() {
    echo "Usage: $0 MODULE"
    echo "Print the Maven profile ids that include the given MODULE in their <modules> list in pom.xml."
    echo
    echo "Positional arguments:"
    echo "  MODULE    module artifactId to search for (exact match)"
    echo
    echo "Example:"
    echo "  $0 my-module-artifact"
}

if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

MODULE="$1"

if ! command -v xmlstarlet >/dev/null 2>&1; then
    echo "Error: xmlstarlet is required but not installed." >&2
    echo "Install it (e.g. on Debian/Ubuntu: sudo apt install xmlstarlet)" >&2
    exit 2
fi

NS="-N x=http://maven.apache.org/POM/4.0.0"

# Print profile ids where the given module appears in <modules>
xmlstarlet sel $NS -t -m "//x:project/x:profiles/x:profile[x:modules/x:module = '$MODULE']" -v "x:id" -n pom.xml 2>/dev/null || true
