#!/bin/bash

tmp_java=InlineJava.java
code="$1"
import="java.util"
static_import="java.lang.System
java.util.Collections"

if [ "$code" == "--help" ]; then
	echo "Executes arbitrary Java code in a 'public static void main' context, with some implicit helper variables/methods, like println and sleep"
	echo "The following imports are built in:"
	echo "java.util.*"
	echo "static java.util.Collections.*"
	echo "static java.lang.System.*"
	exit 0
fi

echo "//`date`" > $tmp_java

for i in $import
do
	echo "import $i.*;" >> $tmp_java
done

for is in $static_import
do
	echo "import static $is.*;" >> $tmp_java
done

echo "
public class InlineJava {
	public static void main(String... args) {
		$code
	}	
	public static void print(Object object) {out.print(object);}
	public static void println(Object object) {out.println(object);}
	public static void printf(String msg, Object... args) {out.printf(msg, args);}
	public static void sleep(long millis) {
		try {Thread.sleep(millis);}
		catch (InterruptedException e) {e.printStackTrace();}
	}
}" >> $tmp_java

javac $tmp_java
tmp_sans_java=${tmp_java/'.java'/''}
java -cp . $tmp_sans_java
rm $tmp_sans_java*

