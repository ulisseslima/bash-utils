#!/bin/bash
# mvn-repository.sh
#
# Usage:
#   ./mvn-repository.sh repositoryId
#
# Resolves and outputs the repository URL from Maven settings.xml for a given repository ID

set -euo pipefail

# Check if repository ID is provided

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 repositoryId" >&2
  echo "Resolves and outputs the repository URL from Maven settings.xml for a given repository ID" >&2
  exit 1
fi

REPO_ID="$1"

echo "🔍 Resolving repository URL for ID: $REPO_ID" >&2

# Find Maven settings.xml file
SETTINGS_FILE=""
if [[ -f "$HOME/.m2/settings.xml" ]]; then
  SETTINGS_FILE="$HOME/.m2/settings.xml"
elif [[ -f "${M2_HOME:-}/conf/settings.xml" ]]; then
  SETTINGS_FILE="${M2_HOME}/conf/settings.xml"
elif [[ -f "/usr/share/maven/conf/settings.xml" ]]; then
  SETTINGS_FILE="/usr/share/maven/conf/settings.xml"
fi


if [[ -z "$SETTINGS_FILE" ]]; then
  echo "❌ Could not find Maven settings.xml file." >&2
  echo "   Expected locations: ~/.m2/settings.xml, \$M2_HOME/conf/settings.xml, /usr/share/maven/conf/settings.xml" >&2
  exit 1
fi

echo "📁 Using settings file: $SETTINGS_FILE" >&2

# Function to extract URL from XML using grep and sed
extract_url_from_xml() {
  local xml_content="$1"
  local repo_id="$2"
  
  # Look for repository with matching ID and extract URL
  echo "$xml_content" | grep -A 10 "<id>$repo_id</id>" | grep -o '<url>[^<]*</url>' | sed 's/<url>\(.*\)<\/url>/\1/' | head -n 1
}

# Read settings.xml content
XML_CONTENT=$(cat "$SETTINGS_FILE")

# Try to find URL in different sections
REPO_URL=""

# 1. Check profiles repositories section first (most common location)
PROFILES_SECTION=$(echo "$XML_CONTENT" | sed -n '/<profiles>/,/<\/profiles>/p')
REPO_URL=$(extract_url_from_xml "$PROFILES_SECTION" "$REPO_ID")

# 2. If not found, check top-level repositories section
if [[ -z "$REPO_URL" ]]; then
  REPOSITORIES_SECTION=$(echo "$XML_CONTENT" | sed -n '/<repositories>/,/<\/repositories>/p')
  REPO_URL=$(extract_url_from_xml "$REPOSITORIES_SECTION" "$REPO_ID")
fi

# 3. If still not found, check servers section (less likely to have URL)
if [[ -z "$REPO_URL" ]]; then
  SERVERS_SECTION=$(echo "$XML_CONTENT" | sed -n '/<servers>/,/<\/servers>/p')
  REPO_URL=$(extract_url_from_xml "$SERVERS_SECTION" "$REPO_ID")
fi


if [[ -z "$REPO_URL" ]]; then
  echo "❌ Could not find repository URL for ID '$REPO_ID' in settings.xml." >&2
  echo "   Please ensure the repository is configured with a <url> element in one of these sections:" >&2
  echo "   - <profiles><profile><repositories><repository><id>$REPO_ID</id><url>...</url></repository></repositories></profile></profiles>" >&2
  echo "   - <repositories><repository><id>$REPO_ID</id><url>...</url></repository></repositories>" >&2
  echo "   - <servers><server><id>$REPO_ID</id><url>...</url></server></servers>" >&2
  exit 1
fi

echo "$REPO_URL"