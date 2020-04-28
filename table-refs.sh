#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

USER=$1
PASSWD="$2"
DB=$3
TABLE=$4

declare -A checked
checked[$TABLE]=YES
level=0

function from() {
    echo "SELECT ccu.table_name tab 
    FROM information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name='$1'"
}

function select_refs() {
    while read table
    do
        TABLE=$table
        if [[ -n "$TABLE" && ${checked[$TABLE]} != YES ]]; then
            level=$((level+1))
            
            checked[$TABLE]=YES
            echo "[$level] $TABLE"
            select_refs
        else
            level=1
        fi
    done < <(psql -U $USER $DB -tc "$(from $TABLE)" | tr -d ' ')
}

export PGPASSWORD="$PASSWD"
select_refs