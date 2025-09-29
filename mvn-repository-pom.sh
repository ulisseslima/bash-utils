#!/bin/bash
# mvn-repository-pom.xml
# Usage: ./mvn-repository-pom.xml <pom.xml>
# Extracts the repository URL (REPO_URL) from the given pom.xml file.

if [ -z "$1" ]; then
  echo "Usage: $0 <pom.xml>" >&2
  exit 1
fi

POM_FILE="$1"

# Try to extract the first <url> inside <repository> or <distributionManagement>/<repository>
REPO_URL=$(awk '/<distributionManagement>/,/<\/distributionManagement>/' "$POM_FILE" | \
  awk '/<repository>/,/<\/repository>/' | \
  grep -m1 '<url>' | \
  sed -E 's/.*<url>([^<]+)<\/url>.*/\1/')

# Fallback: try to extract from <repositories>/<repository>
if [ -z "$REPO_URL" ]; then
  REPO_URL=$(awk '/<repositories>/,/<\/repositories>/' "$POM_FILE" | \
    awk '/<repository>/,/<\/repository>/' | \
    grep -m1 '<url>' | \
    sed -E 's/.*<url>([^<]+)<\/url>.*/\1/')
fi

if [ -n "$REPO_URL" ]; then
  echo "$REPO_URL"
else
  echo "Repository URL not found in $POM_FILE" >&2
  exit 2
fi
