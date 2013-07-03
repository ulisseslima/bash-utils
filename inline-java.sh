#!/bin/bash

tmp_java=InlineJava.java
code="$1"
import='java.util java.text'
static_import="java.lang.System java.util.Collections"

echo_imports() {
	for i in $import
	do
		echo "import $i.*;"
	done
}

echo_static_imports() {
	for is in $static_import
	do
		echo "import static $is.*;"
	done
}

if [ "$code" == "--help" ]; then
	echo "Executes arbitrary Java code in a 'public static void main' context, with some implicit helper variables/methods, like println and sleep"
	echo "The following imports are built in:"
	echo_imports
	echo ""
	echo "The following static imports are built in:"
	echo_static_imports
	echo ""
	echo "You can pass arguments after the code, and access them with a[0] and so on."
	echo ""
	echo "Utility methods:"
	echo "split(Object, String|char...); // splits the string representation of the object using the passed string or array of chars and prints the result"
	exit 0
fi

t1=`date +%s%N | cut -b1-13`

echo "//`date`" > $tmp_java
echo_imports >> $tmp_java
echo_static_imports >> $tmp_java
echo "
public class InlineJava {
	public static void main(String... a) {
		$code
	}
	public static void print(Object object) {
		if (object.getClass().isArray()) out.print(Arrays.toString((Object[]) object));
		else out.print(object);
	}
	public static void println(Object object) {
		if (object.getClass().isArray()) out.println(Arrays.toString((Object[]) object));
		else out.println(object);
	}
	public static void split(Object object, String separator) {
		println(object.toString().split(separator));
	}
	public static void split(Object object, char... separator) {split(object, String.valueOf(separator));}
	public static void printf(String msg, Object... args) {out.printf(msg, args);}
	public static void sleep(long millis) {
		try {Thread.sleep(millis);}
		catch (InterruptedException e) {e.printStackTrace();}
	}
}" >> $tmp_java

javac $tmp_java

t2=`date +%s%N | cut -b1-13`
millis_elapsed=$((t2-t1))
echo "compiled in $millis_elapsed ms."
echo ""

tmp_sans_java=${tmp_java/'.java'/''}
shift
java -cp . $tmp_sans_java $@
rm $tmp_sans_java*

