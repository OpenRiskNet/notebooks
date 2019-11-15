#!/bin/bash
#Find genes that are significant according to each method
a=${1:-50}
echo $a
cat rf_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s'|sort -gr -k2|cut -f1|sort|uniq > significant_variables.txt
b=$(wc -l significant_variables.txt|cut -f1 -d' ')
echo "Number of genes for rf ${b}"
cat knn_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s || $3>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for knn $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
cat regLogistic_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s || $3>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for regLogistic $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
cat gbm_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for gbm $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
cat pam_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a  '$2>s || $3>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for pam $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
cat pls_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for pls $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
cat svmLinear2_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s || $3>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for svmLinear2 $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
cat svmLinear_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s || $3>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for svmLinear $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
cat svmLinearWeights_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s || $3>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for svmLinearWeights $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
cat xgbLinear_variable_importance_run_*.txt |grep -E "^ENS"|awk -v s=$a '$2>s'|cut -f1|sort|uniq >> significant_variables.txt
c=`echo "$(wc -l significant_variables.txt|cut -f1 -d' ') -$b"|bc -l`;
echo "Number of genes for xgbLinear $c"
b=$(wc -l significant_variables.txt|cut -f1 -d' ');
sort significant_variables.txt|uniq > tmp_signif.txt
mv tmp_signif.txt significant_variables.txt
