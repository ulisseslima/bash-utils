#!/bin/bash
# clears ALL `at` jobs
echo "before: $(atq | wc -l)"
for i in `atq | awk '{print $1}'`;do atrm $i;done
echo "after: $(atq | wc -l)"
