#!/bin/bash
# deploy-dir.sh
#
# Usage:
#   ./deploy-dir.sh /path/to/artifact-dir repositoryId
#
# - repositoryId must match the <id> in ~/.m2/settings.xml
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)


set -euo pipefail

# Trap errors and print useful debug info
trap 'echo "[ERROR] Script $ME failed at line $LINENO: $BASH_COMMAND (exit code: $?)" >&2' ERR

ARTIFACT_DIR="$1"
REPO_ID="$2"

# Find the POM
POM_FILE=$(find "$ARTIFACT_DIR" -maxdepth 1 -name "*.pom" | head -n 1)

if [[ -z "$POM_FILE" ]]; then
  echo "❌ No .pom file found in $ARTIFACT_DIR" >&2
  exit 1
else
  echo "📄 Using POM file: $POM_FILE" >&2
fi

# Extract info from POM
GROUP_ID=$(mvn help:evaluate -q -Dexpression=project.groupId -f "$POM_FILE" -DforceStdout)
ARTIFACT_ID=$(mvn help:evaluate -q -Dexpression=project.artifactId -f "$POM_FILE" -DforceStdout)
VERSION=$(mvn help:evaluate -q -Dexpression=project.version -f "$POM_FILE" -DforceStdout)

# Get repo URL from settings.xml via Maven
REPO_URL=$($MYDIR/mvn-repository.sh "$REPO_ID" || echo "[ERROR]")

if [[ -z "$REPO_URL" || "$REPO_URL" == *"[ERROR]"* ]]; then
  echo "❌ Could not detect repository URL. Please add <distributionManagement> in settings.xml or POM." >&2
  exit 1
fi

echo "📦 Deploying to $REPO_ID:"
echo "  GroupId:    '$GROUP_ID'"
echo "  ArtifactId: '$ARTIFACT_ID'"
echo "  Version:    '$VERSION'"
echo "  Repository: '$REPO_URL'"

# Locate files
MAIN_JAR=$(find "$ARTIFACT_DIR" -maxdepth 1 -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | head -n 1)
SOURCES_JAR=$(find "$ARTIFACT_DIR" -maxdepth 1 -name "*-sources.jar" | head -n 1)
JAVADOC_JAR=$(find "$ARTIFACT_DIR" -maxdepth 1 -name "*-javadoc.jar" | head -n 1)


if [[ -z "$MAIN_JAR" ]]; then
  echo "❌ No main JAR file found in $ARTIFACT_DIR, uploading pom only" >&2
  mvn deploy:deploy-file \
    -DrepositoryId="$REPO_ID" \
    -Durl="$REPO_URL" \
    -DpomFile="$POM_FILE" \
    -Dfile="$POM_FILE"
  exit 0
fi

# Deploy main jar + pom
mvn deploy:deploy-file \
  -DrepositoryId="$REPO_ID" \
  -Durl="$REPO_URL" \
  -DpomFile="$POM_FILE" \
  -Dfile="$MAIN_JAR"

# Deploy sources if available
if [[ -n "$SOURCES_JAR" ]]; then
  mvn deploy:deploy-file \
    -DrepositoryId="$REPO_ID" \
    -Durl="$REPO_URL" \
    -DpomFile="$POM_FILE" \
    -Dfile="$SOURCES_JAR" \
    -Dclassifier=sources
fi

# Deploy javadoc if available
if [[ -n "$JAVADOC_JAR" ]]; then
  mvn deploy:deploy-file \
    -DrepositoryId="$REPO_ID" \
    -Durl="$REPO_URL" \
    -DpomFile="$POM_FILE" \
    -Dfile="$JAVADOC_JAR" \
    -Dclassifier=javadoc
fi

echo "✅ Deployment complete!"
