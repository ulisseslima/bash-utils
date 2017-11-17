#!/bin/bash

if [ ! -n "$MAVEN_RESOURCES" ]; then
	echo "var MAVEN_RESOURCES must be defined"
	exit 1
fi
if [ ! -d "$MAVEN_RESOURCES" ]; then
	echo "var MAVEN_RESOURCES must point to an existing directory"
	exit 1
fi

if [ ! -n "$RESOURCES_DESTINATION" ]; then
	echo "var RESOURCES_DESTINATION must be defined"
	exit 1
fi
if [ ! -n "$RESOURCES_DESTINATION" ]; then
	echo "var RESOURCES_DESTINATION must point to an existing directory"
	exit 1
fi

echo "Copying files from $MAVEN_RESOURCES to $RESOURCES_DESTINATION"
cp -r $MAVEN_RESOURCES/* $RESOURCES_DESTINATION
