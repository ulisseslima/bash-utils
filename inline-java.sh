#!/bin/bash

debug() {
	if [ "$verbose" == true ]; then
        	echo "//# $1"
        fi
}

if [ ! -n "$JAVA_HOME" ]; then
	>&2 echo "JAVA_HOME is not defined"
	exit 1
fi

verbose=false
debug=false
# wether the generated files should be kept
keep=false

ClassName="InlineJava`date +%s%N`"

if [ -f "$1" ]; then
	code="`cat $1`"
else
	code="$1"
fi
shift
args=""
import='java.util java.text java.io java.util.regex'
static_import="java.lang.System java.util.Collections"

os=`uname`
pathseparator=':'
fileseparator='/'
if [[ "$os" == *'NT'* ]]; then
	pathseparator=';'
	fileseparator='\'
fi

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
	
	_java=$JAVA_HOME/bin/java

	if [[ "$_java" ]]; then
		version=$(java-version.sh)
		echo "// java version $version"
		if [[ $version > 8 ]]; then
		    cuber="$USR_LIB${fileseparator}cuber.jar"
		    if [ -f "$cuber" ]; then
			echo "import static com.dvlcube.cuber.Cuber.*;"
		    else
			debug "cuber lib not found: $cuber"
		    fi
		else
		    debug "java version less than 8 ($version), some features might be disabled."
		fi
	fi
}

do_help() {
	echo "Executes arbitrary Java code in a 'public static void main' context, with some implicit helper variables/methods, like println and sleep."
	echo "The code to run must be the first argument."
	echo ""
	echo "The following imports are built in:"
	echo_imports
	echo ""
	echo "The following static imports are built in:"
	echo_static_imports
	echo ""
	echo "You can pass arguments after the code, and access them with a[0] and so on. Input from stdin is stored in a string called stdin."
	echo ""
	echo "Utility methods:"
	echo "split(Object, String|char...); // splits the string representation of the object using the passed string or array of chars and prints the result."
}

debug() {
	if [ $verbose == "true" ]; then
		echo "$1"
	fi
}

while test $# -gt 0
do
    case "$1" in
        --verbose|-v) 
        	verbose=true
        	echo "verbose mode on"
        	echo "$JAVA_HOME"
        	java -version
        ;;
	--debug|-d)
		debug=true
	;;
        --help|-h)
        	do_help
        	exit 0
        ;;
	--keep)
		keep=true
		shift
		ClassName=$1
		if [ -n "$ClassName" ]; then
			echo "// keeping as $ClassName"
		else
			>&2 echo "you need to choose a name for the source file as second argument of --keep"
			exit 1
		fi
	;;
	*)
        	args=$args$1" "
	;;
    esac
    shift
done

tmp_java=$ClassName.java

if [ $debug == true ]; then
	echo "USR_LIB: $USR_LIB"
fi
t1=`date +%s%N | cut -b1-13`

echo "//`date`" > $tmp_java
echo_imports >> $tmp_java
echo_static_imports >> $tmp_java
echo "
public class $ClassName {
	public static void main(String... a) throws Exception {
		//double[] n = numbers(a);
		boolean in = false;
		String stdin = \"\";
		try{BufferedReader br=new BufferedReader(new InputStreamReader(System.in));if(br.ready())
			while((stdin=br.readLine())!=null){
			in = true;
			$code
			}}catch(IOException io){io.printStackTrace();}
		if (!in) {$code}
	}
	public static double[] numbers(String[] a) {
		if (a == null || a.length < 1) return null;
		double[] n = new double[a.length];
		for (int i = 0; i < a.length; i++) {
			n[i] = Double.valueOf(a[i]);
		}
		return n;
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
	public static boolean matches(String regex, String string) {
		java.util.regex.Pattern p = java.util.regex.Pattern.compile(regex);
		java.util.regex.Matcher m = p.matcher(string);
		return m.matches();
	}
	public static String datef(String f, Date d) {
		return new SimpleDateFormat(f).format(d);
	}
	public static String capitalize(String s) {
		if (s == null || s.length() == 0) return s;
		s = s.toLowerCase();
		int sLen = s.length();
		StringBuffer buf = new StringBuffer(sLen);
		boolean capNext = true;
		for (int i = 0; i < sLen; i++) {
			char ch = s.charAt(i);
			if (isDelimiter(ch, new char[] { ' ', '_' })) {
				buf.append(' '); capNext = true;
			} else if (capNext) {
				buf.append(Character.toTitleCase(ch)); capNext = false;
			} else buf.append(ch);
		}
		return buf.toString();
	}
	private static boolean isDelimiter(char ch, char[] delimiters) {
		for (int i = 0, isize = delimiters.length; i < isize; i++)
			if (ch == delimiters[i]) return true;
		return false;
	}
	public static void regexTokens(String regex, String string) {
		Pattern p = Pattern.compile(regex);
		Matcher m = p.matcher(string);
		while (m.find())
			for (int i = 1; i <= m.groupCount(); i++)
				System.out.println(m.group(i));
	}
}" >> $tmp_java

if [ -f "$USR_LIB${fileseparator}cuber.jar" ]; then
	$JAVA_HOME/bin/javac -cp "$USR_LIB${fileseparator}cuber.jar${pathseparator}." $tmp_java
else
	javac $tmp_java
fi

if [ $debug == true ]; then
	cat $tmp_java
fi

if [ $verbose = "true" ]; then
	t2=`date +%s%N | cut -b1-13`
	millis_elapsed=$((t2-t1))
	echo "compiled in $millis_elapsed ms."
	echo ""
fi

tmp_sans_java=${tmp_java/'.java'/''}
shift

if [ -f "$USR_LIB${fileseparator}cuber.jar" ]; then
        $JAVA_HOME/bin/java -cp "$USR_LIB${fileseparator}cuber.jar${pathseparator}." $tmp_sans_java $args
else
	java -Xmx1G -cp . $tmp_sans_java $args
fi

if [ $keep != true ]; then
	rm $tmp_sans_java*
else
	debug "$tmp_java kept"
fi
