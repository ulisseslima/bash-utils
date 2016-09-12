#!/bin/sh

control="Package: sictd-desktop
Priority: standard
Section: graphicsuli
Version: 1.3.1.30u
Architecture: i386
Maintainer: DvlCube
Description: Pacote de atualização.
Installed-Size: 34550
"

curr_version=`echo $control | grep 'Version' | cut -d: -f2 | tr -d 'u' | tr -d ' '`

echo "Current version: '$curr_version'"
