#!/bin/bash

if [ $# -lt 4 ]; then
    echo "Usage: $0 dataset Locator-out.txt categoryList.txt X > randomXperCategory.txt";
    exit 0;
fi

echo "single = {data:["
while read line; do
    grep "^$line" $2 | shuf -n $4 > $1.$line.hitinput
    awk --assign D=$1 '{print "{ label:\"" $1 "\", lat:" $5 ", lon:" $6 ", varMi:" $2 ", dataset:\"" D "\" },"}' $1.$line.hitinput
done < $3
echo "]};"