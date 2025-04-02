#!/bin/bash

xmlstarlet sel -N x=http://maven.apache.org/POM/4.0.0 -t -m "//x:project/x:profiles/x:profile" -v "concat(x:id, ': ', x:modules)" -n pom.xml
