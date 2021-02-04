#!/bin/bash
# creates gitlab issue links in a text using hashtag codes
source $(real require.sh)

project="$1"
text="$2"

require project
require text

sed -E "s| #([0-9]+?)| <a title='issue #\1 details' href='https://gitlab.com/$project/-/issues/\1'>#\1</a>|"