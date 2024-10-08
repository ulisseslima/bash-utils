#!/bin/bash
# detail ALL `at` jobs
while read job
do
	job_id=$(echo "$job" | awk '{print $2}')
	echo "$job | $(at-content.sh $job_id)"
done < <(atq -o "%Y-%m-%d %H:%M:%S" | tr '\t' ' ' | awk '{print $2,$1}' | sort)
