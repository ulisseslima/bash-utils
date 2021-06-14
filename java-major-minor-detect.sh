#!/bin/bash
# 51 = 7, 82 = 8 ...

file="$(readlink -f $1)"

if [ ! -f "$file" ]; then
	echo "o primeiro argumento deve ser um arquivo válido. '$file' was not found"
	exit 1
fi

echo "escrevendo..."
echo '
import java.io.*;
public class ClassVersionChecker {
public static void main(String[] args) throws IOException {
    for (int i = 0; i < args.length; i++)
        checkClassVersion(args[i]);
}

    private static void checkClassVersion(String filename)
        throws IOException
    {
        DataInputStream in = new DataInputStream
         (new FileInputStream(filename));

        int magic = in.readInt();
        if(magic != 0xcafebabe) {
          System.out.println(filename + " is not a valid class!");;
        }
        int minor = in.readUnsignedShort();
        int major = in.readUnsignedShort();
        System.out.println(filename + ": " + major + "." + minor);
        in.close();
    }
}' > ClassVersionChecker.java

echo "compilando..."
javac ClassVersionChecker.java

echo "executando..."
java ClassVersionChecker $file

echo "removendo..."
rm ClassVersionChecker*
