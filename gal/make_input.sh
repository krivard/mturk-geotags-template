#!/bin/bash

cut -f 20,33,34 $1 | sed -n '/:/ s/"//gp'
#cut -f 20,30,31,32,33,34 $1 | sed 's/"//g' | awk 'BEGIN{OFS="\t"}{if ($1 != "") print $1,$5,$6 "," $3 "," $2 "," $4}'