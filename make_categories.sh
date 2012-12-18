#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 Locator-xxxx.tsv minCategoryCount > categoryList.txt";
    exit 0;
fi

cut -f 1 $1 | sed 's/:.*//' | sort | uniq -c | awk --assign C=$2 '{if ($1>C) print $2}'
