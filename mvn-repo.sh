#!/bin/bash
# shows maven local repository location
# https://stackoverflow.com/questions/5916157/how-to-get-the-maven-local-repo-location

mvn help:evaluate -Dexpression=settings.localRepository | grep -v '\[INFO\]'
#mvn help:evaluate -Dexpression=settings.localRepository -q -DforceStdout
