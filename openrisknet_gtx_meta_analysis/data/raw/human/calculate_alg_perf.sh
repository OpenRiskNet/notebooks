#!/bin/bash
######
# This script finds an average performance of each algorithm based on its 10 CV runs.
file_name=${1:-algorithms_performance.txt}
work_dir=${2:-./}
cd ${work_dir}
echo ${file_name};
echo ${work_dir};
echo -e "Algorithm\tAccuracy\tSensitivity\tSpecificity" > ${file_name}
for i in $(ls *validation_perf*txt|cut -f1 -d_|sort|uniq); do 
    a=`grep -HE '^Accuracy\s' ${i}_validation_perf*txt|cut -f2|awk 'BEGIN{a=0;}{a=a+$1;}END{print(a/NR);}'`; 
    b=`grep -HE '^Sensitivity\s' ${i}_validation_perf*txt|cut -f2|awk 'BEGIN{a=0;}{a=a+$1;}END{print(a/NR);}'`;
    c=`grep -HE '^Specificity\s' ${i}_validation_perf*txt|cut -f2|awk 'BEGIN{a=0;}{a=a+$1;}END{print(a/NR);}'`; 
    echo -e "${i}\t${a}\t${b}\t${c}" >> ${file_name}; 
done
