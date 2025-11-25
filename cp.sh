#!/bin/bash
# Copies a file preserving its relative directory structure
# Usage: cp.sh <source_file> <destination_dir>

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $(basename "$0") <source_file> <destination_dir>"
    echo ""
    echo "Copies a file while preserving its relative directory structure."
    echo ""
    echo "Example:"
    echo "  $(basename "$0") relative/path/to.file /other/dir"
    echo "  Results in: /other/dir/relative/path/to.file"
    exit 1
fi

SOURCE_FILE="$1"
DEST_DIR="$2"

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file '$SOURCE_FILE' does not exist" >&2
    exit 1
fi

# Build destination path
DEST_PATH="$DEST_DIR/$SOURCE_FILE"

# Create parent directories if they don't exist
DEST_PARENT_DIR=$(dirname "$DEST_PATH")
mkdir -p "$DEST_PARENT_DIR"

# Copy the file
cp "$SOURCE_FILE" "$DEST_PATH"

echo "Copied: $SOURCE_FILE -> $DEST_PATH"
