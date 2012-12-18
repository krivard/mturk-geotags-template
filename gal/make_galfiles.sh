#!/bin/bash


if [ -z "$2" ]; then
    echo "Usage: $0 results.tsv profilename"
    echo "Where ${profilename}.gold exists"
    exit
fi

set -x

WF=`head -1 $1 | sed 's/\t/\n/g' | grep -n WorkerId | sed 's/:.*//'`
CF=`head -1 $1 | sed 's/\t/\n/g' | grep -n category | sed 's/:.*//'`
NF=`head -1 $1 | sed 's/\t/\n/g' | grep -n na_me | sed 's/:.*//'`
QF=`head -1 $1 | sed 's/\t/\n/g' | grep -n quality | sed 's/:.*//'`
ACF=`head -1 $1 | sed 's/\t/\n/g' | grep -n comment | sed 's/:.*//'`

N=`wc -l $1 | awk '{print $1}'`
N=$((N-1))

awk -F "\t" -v kWF=$WF -v kCF=$CF -v kNF=$NF -v QF=$QF -v ACF=$ACF 'BEGIN{OFS="\t"} {split($0,L); print L[kWF],L[kCF] ":" L[kNF], L[QF]}' $1 | tail -$N > $2.input

#cut -f 1,2 $3 > $2.gold

#for f in A B best; do
cut -f 3 $2.input | sort | uniq > $2.categories
./make_costs.pl $2.categories > $2.costs
#done

