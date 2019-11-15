#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

normalized_file="./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized.tsv";
classif_info_file="./classif_info_for_carcinogenomics_human_Liver.tsv";
s_file=" ./s_Liver.txt";

head -n1 ${s_file} |awk -F $'\t' '{print($0"\tarray_file");}'|tr -d '"' | cut -f1,3,24,28,30-34,42,53 -d$'\t' > ${classif_info_file} ;

for i in $(head -1 ${normalized_file}|tr '\t' '\n'|grep 'carcinogenomics_'|grep '.CEL'); do a=`echo $i|sed -re 's/carcinogenomics_//g'`; echo "i=$i a=$a"; b=`grep $a ./a_liver_transcription_profiling_DNA_microarray.txt |cut -f1 -d$'\t'`; echo "a=$a  b=$b"; awk -F$'\t' -v s="$b" -v k=$i  'BEGIN{OFS="\t";}{a=$52; b=s; gsub("[\\?]+","",s); gsub("[\\?]+","",$52); gsub("\"","",s); gsub("\"","",$52); gsub("^","\"",s); gsub("$","\"",s); gsub("^","\"",$52); gsub("$","\"",$52); if(s ~ $52) {gsub($52,a,$52); print($0"\t\""k"\"")}}' ${s_file} |tr -d '"'|cut -f1,3,24,28,30-34,42,53 -d$'\t' >> ${classif_info_file};  done
