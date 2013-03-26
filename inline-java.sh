#!/bin/bash

#######
# Executes arbitrary code in a "public static void main" context
#######

code="$1"

echo "import static java.lang.System.*;
public class InlineJava {
	public static void main(String... args) {
		$code
	}
	
	public static void println(Object object) {out.println(object);}
	public static void printf(String msg, Object... args) {out.printf(msg, args);}
	public static void sleep(long millis) {
		try {Thread.sleep(millis);}
		catch (InterruptedException e) {e.printStackTrace();}
	}
}" > InlineJava.java

javac InlineJava.java
java InlineJava
rm InlineJava*

