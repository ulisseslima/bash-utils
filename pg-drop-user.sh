#!/bin/bash -e
source $(real require.sh)

olduser=$1
require olduser

echo "execute without connecting to any specific database. might be necessary to connect to each one and run the first two commands if the 3rd doesn't work:"
echo "
REASSIGN OWNED BY $olduser TO postgres;
DROP OWNED BY $olduser;
DROP USER $olduser;
"

