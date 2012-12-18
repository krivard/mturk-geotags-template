#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 categoryList.txt dataset1 [dataset2 ...] > hitinput.txt";
    exit 0;
fi


catfile=$1
shift;
start=0
#set -x
for dataset in $@; do
    while read cat; do
	nl -v $start $dataset.$cat.hitinput | awk 'BEGIN {OFS="\t"}{foo=$3; gsub("_"," ",foo); print $1,$2,$3,foo}'
	len=`wc -l $dataset.$cat.hitinput | awk '{print $1}'`
	let start=start+len
    done < $catfile
done
