#!/bin/bash -e
# check what versions of TLS the current JVM supports
source $(real require.sh)

while test $# -gt 0
do
    case "$1" in
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

inline-java.sh '
    javax.net.ssl.SSLContext context = javax.net.ssl.SSLContext.getInstance("TLS");
    context.init(null, null, null);
    String[] supportedProtocols = context.getDefaultSSLParameters().getProtocols();
    System.out.println(Arrays.toString(supportedProtocols));
'