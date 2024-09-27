#!/bin/bash
# detail ALL `at` jobs
while read job
do
	job_id=$(echo "$job" | awk '{print $1}')
	echo "$job | $(at-content.sh $job_id)"
done < <(atq)
