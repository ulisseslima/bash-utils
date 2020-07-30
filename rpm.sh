#!/bin/bash
# pre req: sudo apt-get install rpm rpm2cpio

for thisrpm in *.rpm; do rpm2cpio $thisrpm | cpio -idmv ; done
# TODO move extracted files to target location

for thisrpm in *.rpm; do outscript=$(echo "$thisrpm" | sed -e 's/^\([a-zA-Z0-9_]*\)-.*/\1/').sh ; rpm -qp --scripts $thisrpm | sed -n '/postinstall/,/preuninstall/p' | grep -v ':$' > $outscript ; chmod +x $outscript ; done
