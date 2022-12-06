#!/bin/bash

source $(real require.sh)

check_encoding() {
        f="$1"
        require -f f

        encoding=$(file -i "$f" | cut -d'=' -f2)
        echo ${encoding^^}
}

check_encoding "$1"
