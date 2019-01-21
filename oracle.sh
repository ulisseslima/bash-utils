#!/bin/bash

if [ ! -f "$ORA_JAR" ]; then
	echo "variable ORA_JAR must be defined and pointing to a valid jar file"
	exit 1
fi



java -cp $ORA_JAR:. OracleClient localhost 1521 :xe system oracle 'select cast(current_timestamp as varchar2(50)) from dual'

