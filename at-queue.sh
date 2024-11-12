#!/bin/bash
# detail ALL `at` jobs

filter="$1"

while read job
do
	job_id=$(echo "$job" | awk '{print $2}')
	content=$(at-content.sh $job_id)
	if [[ -n "$filter" ]]; then
		if [[ "${content,,}" == *"${filter,,}"* ]]; then
			echo "filtertedf: $filter"
			echo "$job | $content)"
		fi
	else
		echo "$job | $content)"
	fi
done < <(atq -o "%Y-%m-%d %H:%M:%S" | tr '\t' ' ' | awk '{print $2,$1}' | sort)
