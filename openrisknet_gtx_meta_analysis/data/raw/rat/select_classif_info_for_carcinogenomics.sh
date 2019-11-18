#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

normalized_file="./all_rat_cel_files_tmp/all_rat_cel_files_rma_normalized.tsv";
classif_info_file="./classif_info_for_carcinogenomics_rat_Liver.tsv";
s_file=" ./carcinogenomics/s_Liver.txt";

head -n1 ${s_file} |awk -F $'\t' '{print($0"\tarray_file");}'|tr -d '"' | cut -f1,3,24,28,30-34,42,53 -d$'\t' > ${classif_info_file} ;

#for i in $(head -1 ${normalized_file}|tr '\t' '\n'|grep 'drugmatrix_'|grep '.CEL'); do echo "i=$i"; a=`echo $i|sed -re 's/drugmatrix_//g'`; b=`grep $a ./drugmatrix/a_hepatocyte_transcription_profiling_DNA_microarray.txt  |cut -f1 -d$'\t'`; echo "a=$a b=$b"; awk -F$'\t' -v s="$b" -v k=$i  'BEGIN{OFS="\t";}{a=$52; b=s; gsub("[\\?]+","",s); gsub("[\\?]+","",$52); gsub("\"","",s); gsub("^","\"",s); gsub("$","\"",s); gsub("^","\"",$52); gsub("$","\"",$52); if(s ~ $52) {gsub($52,a,$52); print($0"\t\""k"\"")}}'  ./drugmatrix/s_Hepatocyte.txt |tr -d '"'|cut -f2,3,24,28,30-34,42,52- -d$'\t' >> ${classif_info_file};  done

for i in $(head -1 ${normalized_file}|tr '\t' '\n'|grep 'carcinogenomics_'|grep '.CEL'); do a=`echo $i|sed -re 's/carcinogenomics_//g'`; b=`grep $a ./carcinogenomics/a_liver_transcription_profiling_DNA_microarray.txt |cut -f1 -d$'\t'`; awk -F$'\t' -v s="$b" -v k=$i  'BEGIN{OFS="\t";}{a=$52; b=s; gsub("[\\?]+","",s); gsub("[\\?]+","",$52); gsub("\"","",s); gsub("\"","",$52); gsub("^","\"",s); gsub("$","\"",s); gsub("^","\"",$52); gsub("$","\"",$52); if(s ~ $52) {gsub($52,a,$52); print($0"\t\""k"\"")}}' ${s_file} |tr -d '"'|cut -f1,3,24,28,30-34,42,53 -d$'\t' >> ${classif_info_file};  done
