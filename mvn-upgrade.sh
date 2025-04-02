#!/bin/bash
# upgrade pom dependencies

mvn versions:display-dependency-updates

echo "auto upgrade?"
read confirmation

mvn versions:use-latest-versions
