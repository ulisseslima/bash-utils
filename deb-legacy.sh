#!/bin/bash
# debian 6 doesn't recognize newer formats like .xz, this will repackage it in the gzip format

fix_deb() {
        f=$1

        dpkg-deb -R $f tmp
        rm $f
        fakeroot dpkg-deb -Zgzip -b tmp $f
        rm -rf tmp
}

fix_deb $1
