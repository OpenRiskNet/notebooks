#!/bin/bash
#### 
# This script finds a difference between average accuracy, sensitivity and specificity between two runs of 10fold CV
run_file1=${1};
run_file2=${2};
# file_1=$(tempfile -d /tmp/) || exit;
file_1=${3};
percent=${4};
awk 'BEGIN{FS="\t";a=0;b=0;c=0;};NR>1{a=a+$2;b=b+$3; c=c+$4;}END{print(a/10"\t"b/10"\t"c/10);}' ${run_file1} > $file_1; 
awk 'BEGIN{FS="\t";a=0;b=0;c=0;};NR>1{a=a+$2;b=b+$3; c=c+$4;}END{print(a/10"\t"b/10"\t"c/10);}' ${run_file2} >> $file_1;
awk -v p=${percent} 'BEGIN{FS="\t";f=0}NR==1{a=$1;b=$2; c=$3;}NR==2{if(a-$1>p){f=1;}; if(b-$2>p){f=1}; if(c-$3>p){f=1};print(f)}' $file_1;
#exit;
