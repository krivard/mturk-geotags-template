#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 datasetName Locator-xxxx.tsv minCategoryCount maxVarInMiles sampleSize";
    exit 0;
fi

./make_categories.sh $2 $3 > categoryList.txt
SRC=${2%.tsv}
PRO=$SRC.promoted.tsv
awk --assign M=$4 '{ if ($2<=M) print }' $2 > $PRO
./makedata_js.sh $1 $PRO categoryList.txt $5 > www/all.js
./makedata_hitinput.sh categoryList.txt $1 > hitinput.txt
mkdir -p hitinput
mv *.hitinput hitinput/