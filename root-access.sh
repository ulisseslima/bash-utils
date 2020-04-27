#!/bin/bash

function assert_is_root() {
        if [[ $EUID -ne 0 ]]; then
                echo "this script must be run as root" 1>&2
                exit 1
        fi
}

function assert_not_root() {
        if [[ $EUID -eq 0 ]]; then
                echo "this script must NOT be run as root" 1>&2
                exit 1
        fi
}
