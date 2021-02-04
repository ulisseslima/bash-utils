#!/bin/bash -e
# executar sem conectar em nenhum banco
source $(real require.sh)

olduser=$1
require olduser

echo "
REASSIGN OWNED BY $olduser TO postgres;
DROP OWNED BY $olduser;
DROP USER $olduser;
"
