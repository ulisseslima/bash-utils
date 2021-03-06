#!/bin/bash

tmp_java=/tmp/injava
ClassName=Main

function main() {
echo "
public class $ClassName {
        public static void main(String... a) throws Exception {
                $1
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

javac $tmp_java
tmp_sans_java=${tmp_java/'.java'/''}

java "$@" $tmp_sans_java
}

while read command
do
	read java
	lines="$lines
	$java"

	main "$lines"
done
