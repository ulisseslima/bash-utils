#!/bin/bash
# deploy to a private repository configured in settings.xml
#
# Usage:
#   ./deploy-dir.sh /path/to/artifact-dir repositoryId
#
# - artifact-dir should contain: *.jar, *.pom, *-sources.jar
# - repositoryId must match the <id> configured in your ~/.m2/settings.xml
# - repositoryUrl is the deployment URL (from your repo manager, e.g. Nexus/Artifactory)
set -euo pipefail

ARTIFACT_DIR="$1"
REPO_ID="$2"
REPO_URL="$3"

if [[ ! -d "$ARTIFACT_DIR" ]]; then
  echo "❌ Artifact directory $ARTIFACT_DIR does not exist"
  exit 1
fi

# Find the POM (should be exactly one)
POM_FILE=$(find "$ARTIFACT_DIR" -maxdepth 1 -name "*.pom" | head -n 1)
if [[ -z "$POM_FILE" ]]; then
  echo "❌ No .pom file found in $ARTIFACT_DIR"
  exit 1
fi

# Extract info from POM
GROUP_ID=$(mvn help:evaluate -q -Dexpression=project.groupId -f "$POM_FILE" -DforceStdout)
ARTIFACT_ID=$(mvn help:evaluate -q -Dexpression=project.artifactId -f "$POM_FILE" -DforceStdout)
VERSION=$(mvn help:evaluate -q -Dexpression=project.version -f "$POM_FILE" -DforceStdout)

echo "📦 Deploying to $REPO_ID:"
echo "  GroupId:    $GROUP_ID"
echo "  ArtifactId: $ARTIFACT_ID"
echo "  Version:    $VERSION"

# Locate files
MAIN_JAR=$(find "$ARTIFACT_DIR" -maxdepth 1 -name "*.jar" ! -name "*-sources.jar" | head -n 1)
SOURCES_JAR=$(find "$ARTIFACT_DIR" -maxdepth 1 -name "*-sources.jar" | head -n 1)

if [[ -z "$MAIN_JAR" ]]; then
  echo "❌ No main JAR file found in $ARTIFACT_DIR"
  exit 1
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

echo "✅ Deployment complete!"
