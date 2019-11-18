#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

s_file="../carcinogenomics/s_Liver.txt";
cel_files_dir="../carcinogenomics/liver/micro/";
carcinogenomics_cel_files=${1:-cel_files_carcinogenomics.txt}

echo ${carcinogenomics_cel_files}

join -j 1 <(awk -F $'\t' '$1 ~ /R/ && $1 !~ /_W_/  && $3 ~ /HepaRG/ {print}' ${s_file}|cut -f1|tr -d '"'|sed -re 's/\s+/_/g'|sort) <(ls ${cel_files_dir}|sed -re 's/\.CEL//g'|sort)|sed -re 's/$/.CEL/g'  > ${carcinogenomics_cel_files};
join -j 1 <(awk -F $'\t' '$1 ~ /R/ && $1 !~ /_W_/  && $0 ~ /HepG2\s/ {print}' ${s_file}|cut -f1|tr -d '"'|sed -re 's/\s+/_/g'|sort) <(ls ${cel_files_dir}|sed -re 's/\.CEL//g'|sort)|sed -re 's/$/.CEL/g' >> ${carcinogenomics_cel_files};
join -j 1 <(awk -F $'\t' '$1 ~ /R/ && $1 !~ /_W_/  && $3 !~ /HepG2\// && $3 ~ /HepG2-up/ {print}' ${s_file}|cut -f1|tr -d '"'|sed -re 's/\s+/_/g'|sort) <(ls ${cel_files_dir}|sed -re 's/\.CEL//g'|sort)|sed -re 's/$/.CEL/g' >> ${carcinogenomics_cel_files};
join -j 1 <(awk -F $'\t' '$1 ~ /R/ && $1 !~ /_W_/  && $3 ~ /hESC_DE-Hep/ {print}' ${s_file}|cut -f1|tr -d '"'|sed -re 's/\s+/_/g'|sort) <(ls ${cel_files_dir}|sed -re 's/\.CEL//g'|sort)|sed -re 's/$/.CEL/g' >> ${carcinogenomics_cel_files};
