#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 profilename"
    exit
fi

set -x 

#for f in A B best; do
bin/get-another-label.sh --categories $1.categories --input $1.input --cost $1.costs --gold $1.gold
#cat results/worker-statistics-summary.txt
sed 's/%//g' results/worker-statistics-summary.txt > results/wss.txt
rm -rf $1.results
mv results $1.results
#done

