#!/bin/bash


if [ $# -lt 2 ]; then
    echo "Usage: $0 datasetName Batch_xxxx.csv";
    exit 0;
fi

NEW=${2/%.csv/.tsv}
csv2tsv.pl $2 > $NEW

awk '{print $2 "\t" $3}' ../www/save.results.txt > $1.gold

./make_galfiles.sh $NEW $1
./run_galfiles.sh $1
./make_approvalfile.sh $2 $1
