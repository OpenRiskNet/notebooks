# I usually run make targets sequentially one after another
all: help

help:
	echo "Run make get_data or other targets, usually run one after another sequentially"

# I have downloaded the following dataset online from this URL: https://www.ebi.ac.uk/biostudies/diXa/studies/S-DIXA-042/?query=NTC_WP1.1.8
# It is for compound cisplatin and project code is: S-DIXA-042 also known as 	NTC_WP1.1.8_E01
# Results are located here ./ntc/NTC_WP1.1.8_E01
collect_hg_u133plus2_arrays:
	mkdir hg_u133plus2_arrays
	rsync -auz ../carcinogenomics/Carcinogenomics_extra ./hg_u133plus2_arrays/
	./carcinogenomics_cel_file_names.sh cel_files_carcinogenomics.txt
	mkdir ./hg_u133plus2_arrays/carcinogenomics/
	for i in $$(cat cel_files_carcinogenomics.txt); do rsync -auz ../carcinogenomics/liver/micro/$${i} ./hg_u133plus2_arrays/carcinogenomics/; done
	mkdir hg_u133plus2_arrays/tg_gates/
	find ../tg_gates/in_vitro -iname '*.CEL'|xargs -I{} rsync -auz {} hg_u133plus2_arrays/tg_gates/
	mkdir hg_u133plus2_arrays/magkoufopoulou
	find -L ../magkoufopoulou_hepg2 -iname '*.CEL' |xargs -I{} rsync -auz '{}' hg_u133plus2_arrays/magkoufopoulou/
	rsync -auz ../esnats/ukk4_archive/ hg_u133plus2_arrays/esnats
	rsync -auz ../ketelslegers/Ketelslegers/ hg_u133plus2_arrays/aanjaag_jennen
	mkdir hg_u133plus2_arrays/ntc_4_1_3
	rsync -auz /ngs-data/data_storage/transcriptomics/microarray/mrna/NTC/NTC_WP4.1.3_E02/*CEL ./hg_u133plus2_arrays/ntc_4_1_3/
	mkdir hg_u133plus2_arrays/ntc_1_1_8
	rsync -auz ./ntc/NTC_WP1.1.8_E01/*.CEL ./hg_u133plus2_arrays/ntc_1_1_8/

#Carcinogenomics_extra  aanjaag_jennen  carcinogenomics  esnats  magkoufopoulou  tg_gates
rename_cel_files:
	cd hg_u133plus2_arrays/esnats; rename 's/^/esnats_/g' *.CEL; mv *.CEL ../; cd ../; rm -rf ./esnats/
	cd hg_u133plus2_arrays/aanjaag_jennen; rename 's/^/aanjaag_jennen_/g' *.CEL; mv *.CEL ../; cd ../; rm -rf ./aanjaag_jennen/
	cd hg_u133plus2_arrays/carcinogenomics; rename 's/^/carcinogenomics_/g' *.CEL; mv *.CEL ../; cd ../; rm -rf ./carcinogenomics/
	cd hg_u133plus2_arrays/Carcinogenomics_extra; rename 's/^/Carcinogenomics_extra_/g' *.CEL; mv *.CEL ../; cd ../; rm -rf ./Carcinogenomics_extra/
	cd hg_u133plus2_arrays/magkoufopoulou; rename 's/^/magkoufopoulou_/g' *.CEL; mv *.CEL ../; cd ../; rm -rf ./magkoufopoulou/
	cd hg_u133plus2_arrays/tg_gates; rename 's/^/tg_gates_/g' *.CEL; mv *.CEL ../; cd ../; rm -rf ./tg_gates/
	cd hg_u133plus2_arrays/ntc_4_1_3; rename 's/^/ntc_4_1_3_/g' *.CEL; mv *.CEL ../; cd ../; rm -rf ./ntc_4_1_3/
	cd hg_u133plus2_arrays/ntc_1_1_8; rename 's/^/ntc_1_1_8_/g' *.CEL; mv *.CEL ../; cd ../; rm -rf ./ntc_1_1_8/

md5sums:
	md5sum hg_u133plus2_arrays/*.CEL >> md5sums_hg_u133plus2_arrays.txt

check_md5sums_hg_u133plus2_arrays:
	echo -n "#Number of same files among hg_u133plus2_arrays is: " > same_files_info_hg_u133plus2_arrays.txt
	cut -f1 -d' ' md5sums_hg_u133plus2_arrays.txt |sort|uniq -c|grep -Ev '\s*1\s+'|wc -l >> same_files_info_hg_u133plus2_arrays.txt


#####################
# Normalization part STARTS here.
#####################

# Apparently we don't need carcinogenomics CEL files from VUB lab.
# Don't use this target from now on, because I select carcinogenomics files specifically per cell type
#remove_carcinogenomics_vub:
#	rm hg_u133plus2_arrays/carcinogenomics_VUB-*.CEL

normalize_hg_u133plus2_arrays:
	sed -re 's/rat2302rnensgcdf/hgu133plus2hsensgcdf/g; s/rat\/all_rat_cel_files_tmp\//human\/hg_u133plus2_arrays\//g; s/all_rat_cel_files_rma_normalized/human_hg_u133plus2_arrays_normalized/; s/ rat CEL / human hg_u133plus2_arrays CEL/' ../rat/normalize_all_rat_arrays_liver.R > normalize_human_hg_u133plus2_arrays_liver.R
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/human/normalize_human_hg_u133plus2_arrays_liver.R >> normalization_run_time_human_hg_u133plus2_arrays.txt

collect_hg_u133_pm_cel_files:
	mkdir hg_u133_pm
	sed -re 's#^#../deferme/#g' ../deferme/array_files_of_GPL15798.txt > deferme_GSE58235_RAW_GPL15798.txt
	for i in $$(cat deferme_GSE58235_RAW_GPL15798.txt); do rsync -auz $$i ./hg_u133_pm/; done
	rsync -auz ../deferme/lize_3compounds_archive/*.CEL ./hg_u133_pm/

md5sums_hg_u133_pm:
	md5sum hg_u133_pm/*.CEL >> md5sums_hg_u133_pm_arrays.txt

check_md5sums_hg_u133_pm_arrays:
	echo -n "#Number of same files among hg_u133_pm_arrays is: " > same_files_info_hg_u133_pm_arrays.txt
	cut -f1 -d' ' md5sums_hg_u133_pm_arrays.txt |sort|uniq -c|grep -Ev '\s*1\s+'|wc -l >> same_files_info_hg_u133_pm_arrays.txt

normalize_hg_u133_pm_arrays:
	sed -re 's/hgu133plus2hsensgcdf/hthgu133pluspmhsensgcdf/g; s/\/hg_u133plus2_arrays/\/hg_u133_pm/g; s/human_hg_u133plus2_arrays_normalized/human_hg_u133_pm_arrays_normalized/; s/ human hg_u133plus2_arrays CEL/ human hg_u133_pm CEL/' normalize_human_hg_u133plus2_arrays_liver.R > normalize_human_hg_u133_pm_arrays_liver.R
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/human/normalize_human_hg_u133_pm_arrays_liver.R >> normalization_run_time_human_hg_u133_pm_arrays.txt

collect_hg_u133a_2_arrays:
	mkdir hg_u133a_2
	rsync -auz ../predictomics/*.CEL ./hg_u133a_2/

md5sums_hg_u133a_2:
	md5sum hg_u133a_2/*.CEL >> md5sums_hg_u133a_2_arrays.txt

check_md5sums_hg_u133a_2_arrays:
	echo -n "#Number of same files among hg_u133a_2_arrays is: " > same_files_info_hg_u133a_2_arrays.txt
	cut -f1 -d' ' md5sums_hg_u133a_2_arrays.txt |sort|uniq -c|grep -Ev '\s*1\s+'|wc -l >> same_files_info_hg_u133a_2_arrays.txt

normalize_hg_u133a_2_arrays:
	sed -re 's/hgu133plus2hsensgcdf/hgu133a2hsensgcdf/g; s/\/hg_u133plus2_arrays/\/hg_u133a_2/g; s/human_hg_u133plus2_arrays_normalized/human_hg_u133a_2_arrays_normalized/; s/ human hg_u133plus2_arrays CEL/ human hg_u133a_2 CEL/' normalize_human_hg_u133plus2_arrays_liver.R > normalize_human_hg_u133a_2_arrays_liver.R
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/human/normalize_human_hg_u133a_2_arrays_liver.R >> normalization_run_time_human_hg_u133a_2_arrays.txt

#####################
# Normalization part ENDS here.
#####################

###
# We ignore hg_u133a_2 arrays at least for now, because it has much less number of genes compared to the other two array platforms
###
## I am using the old meta-info files, so no need to regenerate it
#classify_info_carcinogenomics:
#	ln -s ../carcinogenomics/s_Liver.txt .
#	ln -s ../carcinogenomics/a_liver_transcription_profiling_DNA_microarray.txt .
#	./select_classif_info_for_carcinogenomics.sh

# Before normalizing I have collected each CEL file under project name and then prepended to cel file name "project_"
# The next target will remove that prepended part

#####################
# Adding class information for each sample STARTS here.
#####################

change_header_names:
	sed -re 's/esnats_//g' ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized.tsv > ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv
	sed -ire 's/aanjaag_jennen_//g' ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv
	sed -ire 's/carcinogenomics_//g'  ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv
	sed -ire 's/Carcinogenomics_extra_//g' ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv
	sed -ire 's/magkoufopoulou_//g'  ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv
	sed -ire 's/tg_gates_//g' ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv
	sed -ire 's/ntc_4_1_3_//g' ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv
	sed -ire 's/ntc_1_1_8_//g' ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv

ratio_info_files_hg_u133plus2:
	cp  ../../processed/training_meta_info/classif_info_for_carcinogenomics_extra.tsv ratio_info_human_arrays_hg_u133plus2.tsv
	awk 'NR>1' ../../processed/training_meta_info/classif_info_for_carcinogenomics_all.tsv >> ratio_info_human_arrays_hg_u133plus2.tsv
	awk 'NR>1' ../../processed/training_meta_info/classif_info_for_tg_gates.tsv >> ratio_info_human_arrays_hg_u133plus2.tsv
	awk 'NR>1' ../../processed/training_meta_info/classif_info_for_magkoufopoulou.tsv >> ratio_info_human_arrays_hg_u133plus2.tsv
	awk 'NR>1' ../../processed/training_meta_info/classif_info_for_esnats.tsv|sed -re 's/study10_/study08_/g' >> ratio_info_human_arrays_hg_u133plus2.tsv
	awk 'NR>1' ../../processed/training_meta_info/classif_info_for_ntc_wp4_1_3.tsv|sed -re 's/study11_/study09_/g' >> ratio_info_human_arrays_hg_u133plus2.tsv
	awk 'NR>1' ../../processed/training_meta_info/classif_info_for_ketelslegers.tsv|sed -re 's/study12_/study10_/g' >> ratio_info_human_arrays_hg_u133plus2.tsv 
	awk 'NR>1' ./ntc/classify_info_ntc_1.1.8_correct.tsv >> ratio_info_human_arrays_hg_u133plus2.tsv

average_ratio_hg_u133plus2:
	mkdir average_ratio
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./hg_u133plus2_arrays/human_hg_u133plus2_arrays_normalized_new_names.tsv ./ratio_info_human_arrays_hg_u133plus2.tsv ./average_ratio/human_hg_u133plus2_arrays_normalized_avg_ratio.tsv|tee ./generation_of_ratio_info_human_arrays_hg_u133plus2.log

ratio_info_files_hg_u133_pm:
	sed -re 's/study14_/study12_/g' ../../processed/training_meta_info/classif_info_for_deferme_lize.tsv > ratio_info_human_arrays_hg_u133_pm.tsv
	awk 'NR>1' ../../processed/training_meta_info/classif_info_deferme_GSE58235_GPL15798_series.tsv >> ratio_info_human_arrays_hg_u133_pm.tsv


average_ratio_hg_u133_pm:
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./hg_u133_pm/human_hg_u133_pm_arrays_normalized.tsv ./ratio_info_human_arrays_hg_u133_pm.tsv ./average_ratio/human_hg_u133_pm_arrays_normalized_avg_ratio.tsv

join_files_on_gene_id:
	/bin/bash -c "join -j 1 -t $$'\t' <(sort ./average_ratio/human_hg_u133plus2_arrays_normalized_avg_ratio.tsv) <(sort ./average_ratio/human_hg_u133_pm_arrays_normalized_avg_ratio.tsv) |sed -re 's/_at//g' > ./average_ratio/normalized_join_on_gene_ids_u133plu2_u133pm.tsv"

# We are not using the next target for now
transpose:
	R --file=transpose_table.R --args average_ratio/normalized_join_on_gene_ids_u133plu2_u133pm.tsv average_ratio/normalized_join_on_gene_ids_u133plu2_u133pm_T.tsv

add_class_info:
	a=$$(tempfile -d '.'); awk 'NR>1' ratio_info_human_arrays_hg_u133_pm.tsv > $$a; \
	cat ratio_info_human_arrays_hg_u133plus2.tsv  $$a > ./average_ratio/ratio_info_human_array_platforms_u133plus2_u133pm.tsv && rm $$a;
	cut -f1 average_ratio/normalized_join_on_gene_ids_u133plu2_u133pm.tsv|grep ENSG > ./average_ratio/genes_present_in_both_platforms.tsv
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  average_ratio/normalized_join_on_gene_ids_u133plu2_u133pm.tsv ./average_ratio/ratio_info_human_array_platforms_u133plus2_u133pm.tsv ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv ./average_ratio/genes_present_in_both_platforms.tsv|tee ./average_ratio/generation_of_all_data_human_array_platforms_u133plus2_u133pm.log

# This step SHOULD no longer be necessary, because I corrected the script src/data/convert_to_caret_input_format.R. However, I didn't test it yet
correct_no_class_info:
	cd average_ratio; \
	mv all_data_human_array_platforms_u133plus2_u133pm.tsv all_data_human_array_platforms_u133plus2_u133pm.tsv.old; \
	head -n 1 all_data_human_array_platforms_u133plus2_u133pm.tsv.old > all_data_human_array_platforms_u133plus2_u133pm.tsv; \
	grep GTX all_data_human_array_platforms_u133plus2_u133pm.tsv.old >> all_data_human_array_platforms_u133plus2_u133pm.tsv;

#####################
# Adding class information for each sample ENDS here.
#####################


#####################
# Classification part STARTS here.
#####################
split_train_test:
	cd average_ratio; \
	head -1 all_data_human_array_platforms_u133plus2_u133pm.tsv > training_data_human_arrays.tsv; \
	head -1 all_data_human_array_platforms_u133plus2_u133pm.tsv > test_data_human_arrays.tsv; \
	awk 'NR>1{a=rand(); if(a<=0.2){print >> "test_data_human_arrays.tsv";}else{print >> "training_data_human_arrays.tsv";}}' all_data_human_array_platforms_u133plus2_u133pm.tsv

run_classification:
	mkdir -pv classification/run1;
	rsync -auz average_ratio/training_data_human_arrays.tsv ./classification/
	rsync -auz average_ratio/test_data_human_arrays.tsv ./classification/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret.R --args $$(pwd)/classification/run1/ /share/data/openrisknet/dixa_classification/data/raw/human/classification/training_data_human_arrays.tsv /share/data/openrisknet/dixa_classification/data/raw/human/classification/test_data_human_arrays.tsv|tee classification/run1.log

# This target was created to generate pdf image of the bwplot
run_classification2:
	mkdir -pv classification/run2;
	rsync -auz average_ratio/training_data_human_arrays.tsv ./classification/
	rsync -auz average_ratio/test_data_human_arrays.tsv ./classification/
	echo "Classification STARTED at: $$(date)" > classification/run2/run2_period.txt;
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret.R --args $$(pwd)/classification/run2/ /share/data/openrisknet/dixa_classification/data/raw/human/classification/training_data_human_arrays.tsv /share/data/openrisknet/dixa_classification/data/raw/human/classification/test_data_human_arrays.tsv|tee classification/run2.log
	echo "Classification FINISHED at: $$(date)" >> classification/run2/run2_period.txt;

# 10 fold cross-validation based classification
separateCV_classification:
	mkdir -pv cross_val_classification/;
	echo "Task separateCV_classification STARTED at: $$(date)" > ./cross_val_classification/run_time.txt;
	rsync -auz ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv ./cross_val_classification/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV.R --args $$(pwd)/cross_val_classification/ /share/data/openrisknet/dixa_classification/data/raw/human/cross_val_classification/all_data_human_array_platforms_u133plus2_u133pm.tsv 10|tee ./cross_val_classification/run.log
	echo "Task separateCV_classification FINISHED at: $$(date)" >> ./cross_val_classification/run_time.txt;


# 10 fold cross-validation based classification
# Added on 13 June 2019
# Due to write permission errors on my home folder after Ubuntu upgrade I currently copied two scripts jb_caret_withSeparateCV_exclusive_split.R and jb_caret_noCV_noUnivarFilter_selectedGenes.R
# to one folder above the parent folder of this Makefile. So, these two scripts are available at $(CDW)/../
separateCV_classification_exclusive:
	mkdir -pv cross_val_classification_exclusive/;
	echo "Task separateCV_classification_exclusive  STARTED at: $$(date)" > ./cross_val_classification_exclusive/run_time.txt;
	rsync -auz ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv ./cross_val_classification_exclusive/
	export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/3.5/ && R -q --max-ppsize=500000 --file=/share/data/openrisknet/dixa_classification/data/raw/jb_caret_withSeparateCV_exclusive_split.R --args $$(pwd)/cross_val_classification_exclusive/ /share/data/openrisknet/dixa_classification/data/raw/human/cross_val_classification_exclusive/all_data_human_array_platforms_u133plus2_u133pm.tsv 10|tee ./cross_val_classification_exclusive/run.log
	echo "Task  separateCV_classification_exclusive FINISHED at: $$(date)" >> ./cross_val_classification_exclusive/run_time.txt;


separateCV_classif_univar_exclusive:
	mkdir -pv cross_val_classif_univar_exclusive/;
	echo "Task separateCV_classif_univar_exclusive STARTED at: $$(date)" > ./cross_val_classif_univar_exclusive/run_time.txt;
	rsync -auz ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv ./cross_val_classif_univar_exclusive/
	export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/3.5/ && R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_afterUnivarFilter_exclusive_split.R  --args $$(pwd)/cross_val_classif_univar_exclusive/ /share/data/openrisknet/dixa_classification/data/raw/human/cross_val_classif_univar_exclusive/all_data_human_array_platforms_u133plus2_u133pm.tsv 10|tee ./cross_val_classif_univar_exclusive/run.log
	echo "Task separateCV_classif_univar_exclusive FINISHED at: $$(date)" >> ./cross_val_classif_univar_exclusive/run_time.txt;


# 10 fold cross-validation based classification after univariate filtering
separateCV_classif_univar_filter:
	mkdir -pv cross_val_classif_univar_filter/;
	echo "Task separateCV_classif_univar_filter STARTED at: $$(date)" > ./cross_val_classif_univar_filter/run_time.txt;
	rsync -auz ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv ./cross_val_classif_univar_filter/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_afterUnivarFilter.R --args $$(pwd)/cross_val_classif_univar_filter/ /share/data/openrisknet/dixa_classification/data/raw/human/cross_val_classif_univar_filter/all_data_human_array_platforms_u133plus2_u133pm.tsv 10|tee ./cross_val_classif_univar_filter/run.log
	echo "Task separateCV_classif_univar_filter FINISHED at: $$(date)" >> ./cross_val_classif_univar_filter/run_time.txt;


# 10 fold cross-validation based classification for selected set of genes, which were based on 10-fold cross-validation univariate filtering of the target separateCV_classif_univar_filter
# This target is almost identical to the previous target selected_genes_cross_val, except it will be used by the next target iterative_gene_selection to run gene selection in more or less an isolated folder
# Here an isolated folder is just a separate folder, so this target will not create a new directory. It will just work in a directory, where it was called.
select_genes_cross_val_isolated:
	echo "Task selected_genes_cross_val_isolated STARTED at: $$(date)" > run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_selectedGenesOnly.R --args $$(pwd)/ /share/data/openrisknet/dixa_classification/data/raw/human/cross_val_classif_univar_filter/all_data_human_array_platforms_u133plus2_u133pm.tsv 10 $$(pwd)/../significant_variables.txt|tee ./run.log
	echo "Task selected_genes_cross_val_isolated FINISHED at: $$(date)" >> ./run_time.txt;

# The following target is an iterative process of removing genes based on the decrease in average accuracy, average sensitivity and average specificity
# If after removing insignificant genes average accucary doesn't decrease more than X% (X=10, here) then continue removing the genes.
# Here the baseline average accuracy, sensitivity and specificity are taken from the first round of gene selection
iterative_gene_selection:
	mkdir -pv iterative_gene_selection
#	The file selected_genes_cross_val/significant_variables.txt is generated by select_best_features.sh
	cp ../mouse/select_best_features.sh ./cross_val_classif_univar_filter/
	cd cross_val_classif_univar_filter && ./select_best_features.sh 75
	cp cross_val_classif_univar_filter/significant_variables.txt ./iterative_gene_selection/significant_variables_base.txt
	cp ./cross_val_classif_univar_filter/select_best_features.sh ./iterative_gene_selection/
	./calculate_alg_perf.sh algorithms_performance_before_gene_selection.txt ./cross_val_classif_univar_filter/
	cp ./cross_val_classif_univar_filter/algorithms_performance_before_gene_selection.txt ./iterative_gene_selection/
	cd ./iterative_gene_selection/; \
	ln -s significant_variables_base.txt significant_variables.txt; \
	echo "Task iterative_gene_selection STARTED at: $$(date)" > run_time.txt; \
	for r in $$(seq 1 20); do echo "STARTED run $${r} at: $$(date)" >> run_time.txt; mkdir run_$${r}; cp ../Makefile ./run_$${r}; cd ./run_$${r}; make select_genes_cross_val_isolated; cp ../../calculate_alg_perf.sh .; ./calculate_alg_perf.sh alg_perf_gene_selection_run_$${r}.txt; cp ../select_best_features.sh .;  ./select_best_features.sh 75; cd ../; a=$$(../find_avg_perf_diff.sh ./algorithms_performace_before_gene_selection.txt ./run_$${r}/alg_perf_gene_selection_run_$${r}.txt avg_perf_diff_base_vs_run_$${r}.txt 0.1); if(($$a==1)); then echo "Gene selection decreased average performance metric at least 10%. So stopping gene selection at run $${r}"; break; fi;echo "FINISHED run $${r} at: $$(date)" >> run_time.txt; b=$$(cmp significant_variables.txt run_$${r}/significant_variables.txt); if [ "$$b" == "" ]; then echo "No new feature was filtered between two steps, so exiting now at the finish of step $${r}"; break; fi; rm significant_variables.txt; ln -s ./run_$${r}/significant_variables.txt .; done; \
	echo "Task iterative_gene_selection FINISHED at: $$(date)" >> run_time.txt;



# The following command was used to generate a validation performance table for all algs. Currently it is an incomplete target, it is just a bash command.
# The resulted table was then manually modified
#val_perf_table
#	echo -e "Algorithm\tAccuracy\tSensitivity\tSpecificity" > algorithms_performance.txt && for i in $(ls *validation_perf*txt|cut -f1 -d_|sort|uniq); do a=`grep -HE '^Accuracy\s' ${i}_validation_perf*txt|cut -f2|awk 'BEGIN{a=0;}{a=a+$1;}END{print(a/NR);}'`; b=`grep -HE '^Sensitivity\s' ${i}_validation_perf*txt|cut -f2|awk 'BEGIN{a=0;}{a=a+$1;}END{print(a/NR);}'`;c=`grep -HE '^Specificity\s' ${i}_validation_perf*txt|cut -f2|awk 'BEGIN{a=0;}{a=a+$1;}END{print(a/NR);}'`; echo -e "${i}\t${a}\t${b}\t${c}" >> algorithms_performance.txt; done

#####################
# Classification part ENDS here.
#####################


#####################
# Orthology related part. This part is ignored, because orthology-based multi-species model didn't perform well compare to the species-specific model.
#####################
get_orthologs:
	mkdir -pv orthologs
	head -1 average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv|cut -f3-|tr '\t' '\n' > ./orthologs/human_genes.txt
	python /home/jbayjanov/projects/tgx/dixa_classification/src/orthology/orthologs.py ./orthologs/human_genes.txt ./orthologs/human_genes_orthologs_ mouse,rat

common_orthologs:
	head -1 ../mouse/average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv|cut -f3-|tr '\t' '\n'|sort |uniq > ./orthologs/mouse.txt
	cat ./orthologs/human_genes_orthologs_REST_6.3_DB_92_API_92.tsv |grep ENSMUSG|sort -k2|uniq > ./orthologs/mouse_h.txt
	/bin/bash -c "join -1 2 -2 1 -t $$'\t' ./orthologs/mouse_h.txt  ./orthologs/mouse.txt |grep one2one|sort -k2 >  ./orthologs/mouse_human.txt"
	head -1 ../rat/average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv|cut -f3-|sed -re 's/_at//g'|tr '\t' '\n'|sort|uniq >  ./orthologs/rat.txt
	cat ./orthologs/human_genes_orthologs_REST_6.3_DB_92_API_92.tsv |grep ENSRNOG|sort -k2|uniq > ./orthologs/rat_h.txt
	/bin/bash -c "join -1 2 -2 1 -t $$'\t' ./orthologs/rat_h.txt  ./orthologs/rat.txt |grep one2one|sort -k2 >  ./orthologs/rat_human.txt"
	/bin/bash -c "join -j 2 -t $$'\t'  ./orthologs/mouse_human.txt  ./orthologs/rat_human.txt >  ./orthologs/common_one2one_orthologs_human_mouse_rat_all_info.tsv"
	echo  "human\tmouse\trat" > ./orthologs/common_one2one_orthologs_human_mouse_rat.tsv
	cut -f1,2,6 ./orthologs/common_one2one_orthologs_human_mouse_rat_all_info.tsv >> ./orthologs/common_one2one_orthologs_human_mouse_rat.tsv
	rm ./orthologs/mouse_h.txt ./orthologs/rat_h.txt


######
# Orthology part
# Using the orthologs that are common among all 3 species classify the data again
######

orthologs_separateCV:
	mkdir -pv ./classification/orthologs_cv
	echo "Task orthologs_separateCV STARTED at: $$(date)" > ./classification/orthologs_cv/run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_common_orthologs_withSeparateCV.R --args $$(pwd)/classification/orthologs_cv/ /share/data/openrisknet/dixa_classification/data/raw/human/average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv $$(pwd)/orthologs/common_one2one_orthologs_human_mouse_rat.tsv 1|tee ./classification/orthologs_cv/run.log
	echo "Task orthologs_separateCV FINISHED at: $$(date)" >> ./classification/orthologs_cv/run_time.txt;



#####################
# Validation part STARTS here.
#####################


# The following steps are for BE-BASIC data analysis as test data and these steps are more or less similar to NRW data analysis steps
# ratio_info files were done curated manually
be_basic_prepare_data:
	mkdir -pv be_basic # After this step manually curated files are moved here
	mkdir -pv be_basic/array_data/
	for i in $$(cut -f15 ./be_basic/ratio_info_for_BE_Basic_data_manually_edited_new.tsv|grep '.CEL'); do rsync -auvz /share/data/undefined_projects/lucas/data/BE-BASIC/all_training_validation_cell_files/$${i} ./be_basic/array_data/; done

# BE-Basic data was already normalized with RMA and the R script is also present there, so I will just copy them here into be_basic folder
# However, then it turned out that some samples were tested twice, so I need to re-normalize all arrays without those doubles
be_basic_normalize_data:
	echo "Task be_basic_normalize_data STARTED  at $$(date)" > ./be_basic/be_basic_normalize_data_run_time.txt; 
	sed -re 's#/BE-BASIC/all_training_validation_cell_files/#/be_basic/array_data/#; s#human_hg_u133_pm_arrays_normalized.tsv#human_hg_u133_pm_arrays_be_basic_normalized.tsv#' /share/data/undefined_projects/lucas/data/BE-BASIC/normalize_human_hg_u133_pm_arrays_liver.R > ./be_basic/normalize_human_hg_u133_pm_arrays_be_basic.R
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/human/be_basic/:/be_basic/ r_base_3.4.0:array R --file=/be_basic/normalize_human_hg_u133_pm_arrays_be_basic.R >> ./be_basic/normalization_run_time_human_hg_u133_pm_arrays_be_basic.txt
	echo "Task be_basic_normalize_data FINISHED at $$(date)" >> ./be_basic/be_basic_normalize_data_run_time.txt;

# Like before I manually created and edited the file ratio file
be_basic_average_ratio:
	mkdir -pv ./be_basic/average_ratio
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./be_basic/array_data/human_hg_u133_pm_arrays_be_basic_normalized.tsv ./be_basic/ratio_info_for_BE_Basic_data_manually_edited_new.tsv ./be_basic/average_ratio/be_basic_normalized_avg_ratio.tsv

be_basic_class_info:
	cut -f1 ./be_basic/average_ratio/be_basic_normalized_avg_ratio.tsv|grep ENSG > ./be_basic/average_ratio/gene_names_in_be_basic_data.txt;
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  ./be_basic/average_ratio/be_basic_normalized_avg_ratio.tsv  ./be_basic/ratio_info_for_BE_Basic_data_manually_edited_new.tsv   ./be_basic/average_ratio/be_basic_normalized_avg_ratio_class_info.tsv ./be_basic/average_ratio/gene_names_in_be_basic_data.txt | tee ./be_basic/run_be_basic_normalized_avg_ratio_class_info.log

# In this target, first I wanted to get rid of the ENSG00000075624 from ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv,
# but it is NOT needed, because that gene that are present in be_basic data will not be used
# The reason this gene being absent is that all human data contains different array platforms and in one of them this gene was absent, so it was discarded.
be_basic_separateCV_classif_univar_filter:
	mkdir -pv ./be_basic/cross_val_classif_univar_filter/;
	echo "Task be_basic_separateCV_classif_univar_filter STARTED at: $$(date)" > ./be_basic/cross_val_classif_univar_filter/run_time.txt; 
	cat ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv |sed -re 's/_at\t/\t/g; s/_at$$//' >  ./be_basic/cross_val_classif_univar_filter/all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv
	rsync -auvz ./be_basic/average_ratio/be_basic_normalized_avg_ratio_class_info.tsv  ./be_basic/cross_val_classif_univar_filter/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV_UnivarFilter_NRW.R --args $$(pwd)/be_basic/cross_val_classif_univar_filter/ /share/data/openrisknet/dixa_classification/data/raw/human/be_basic/cross_val_classif_univar_filter/all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv $$(pwd)/be_basic/cross_val_classif_univar_filter/be_basic_normalized_avg_ratio_class_info.tsv|tee ./be_basic/cross_val_classif_univar_filter/run_be_basic_cv_class_univar.log
	echo "Task be_basic_separateCV_classif_univar_filter FINISHED at: $$(date)" >> ./be_basic/cross_val_classif_univar_filter/run_time.txt;

# This task is very similar to be_basic_separateCV_classif_univar_filter, but has no univariate filtering and expression values are also unit-scaled.
be_basic_classif_no_univar:
	mkdir -pv ./be_basic/classif_no_univar/;
	echo "Task be_basic_classif_no_univar STARTED at: $$(date)" > ./be_basic/classif_no_univar/run_time.txt; 
	cat ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv |sed -re 's/_at\t/\t/g; s/_at$$//' >  ./be_basic/classif_no_univar/all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv
	rsync -auvz ./be_basic/average_ratio/be_basic_normalized_avg_ratio_class_info.tsv  ./be_basic/classif_no_univar/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV_noUnivarFilter.R --args $$(pwd)/be_basic/classif_no_univar/ /share/data/openrisknet/dixa_classification/data/raw/human/be_basic/classif_no_univar/all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv $$(pwd)/be_basic/classif_no_univar/be_basic_normalized_avg_ratio_class_info.tsv|tee ./be_basic/classif_no_univar/run_be_basic_classif_no_univar.log
	echo "Task be_basic_classif_no_univar FINISHED at: $$(date)" >> ./be_basic/classif_no_univar/run_time.txt;


# This task is very similar to be_basic_classif_no_univar, but only uses selected genes based on the iterative gene selection
significant_genes_be_basic_classif_no_univar:
	mkdir -pv ./be_basic/signif_genes_classif_no_univar/;
	echo "Task significant_genes_be_basic_classif_no_univar STARTED at: $$(date)" > ./be_basic/signif_genes_classif_no_univar/run_time.txt; 
	cat ./average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv |sed -re 's/_at\t/\t/g; s/_at$$//' >  ./be_basic/signif_genes_classif_no_univar/all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv
	rsync -auvz ./be_basic/average_ratio/be_basic_normalized_avg_ratio_class_info.tsv  ./be_basic/signif_genes_classif_no_univar/
	export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/3.5/ && R -q --max-ppsize=500000 --file=/share/data/openrisknet/dixa_classification/data/raw/jb_caret_noCV_noUnivarFilter_selectedGenes.R --args $$(pwd)/be_basic/signif_genes_classif_no_univar/ /share/data/openrisknet/dixa_classification/data/raw/human/be_basic/signif_genes_classif_no_univar/all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv $$(pwd)/be_basic/signif_genes_classif_no_univar/be_basic_normalized_avg_ratio_class_info.tsv /share/data/openrisknet/dixa_classification/data/raw/human/iterative_gene_selection/run_2/significant_variables.txt|tee ./be_basic/signif_genes_classif_no_univar/run_significant_genes_be_basic_classif_no_univar.log
	echo "Task signif_genes_classif_no_univar FINISHED at: $$(date)" >> ./be_basic/signif_genes_classif_no_univar/run_time.txt;

#######
# Generate mas5 normalized images of arrays
#######
# Below and elsewhere MAS5 normalization is not correct, because we also needed MM values which we don't have.
# So, MAS5 normalized data is not used and the R package that does MAS5 normalization is just returning scaled values.
# This should have been clearly stated in the package's documentation.

# The file create_mas5_images_template.R was generated by modifying normalize_human_hg_u133plus2_arrays_liver.R
image_mas5_hg_u133plus2_arrays:
	sed -re 's#ARRAY_FOLDER#hg_u133plus2_arrays#g; s#images_folder="XXX"#images_folder="mas5_images"#' create_mas5_images_template.R > create_mas5_images_human_hg_u133plus2_arrays_liver.R 
	mkdir -pv ./hg_u133plus2_arrays/mas5_images
	mkdir -pv ./hg_u133plus2_arrays/mas5_normalized
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/human/create_mas5_images_human_hg_u133plus2_arrays_liver.R >> image_mas5_run_time_human_hg_u133plus2_arrays.txt 2>&1

image_mas5_hg_u133_pm_arrays:
	sed -re 's#ARRAY_FOLDER#hg_u133_pm#g; s#images_folder="XXX"#images_folder="mas5_images"#g; s#hgu133plus2hsensgcdf#hthgu133pluspmhsensgcdf#g;' create_mas5_images_template.R > create_mas5_images_human_hg_u133_pm_arrays_liver.R 
	mkdir -pv ./hg_u133_pm/mas5_images
	mkdir -pv ./hg_u133_pm/mas5_normalized
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/human/create_mas5_images_human_hg_u133_pm_arrays_liver.R >> image_mas5_run_time_human_hg_u133_pm_arrays.txt 2>&1

# The above two image_mas5* targets may not be necessary, because first I want to normalize all arrays and store them in a large 
# tsv file and then once all arrays with different platforms are normalized then I can create an image based on the overlapping genes that are present in all platforms
# See the next target normalize_mas5_hg_u133plus2_arrays_split, becausethere are a lot of arrays
normalize_mas5_hg_u133plus2_arrays:
	sed -re 's/human_hg_u133plus2_arrays_normalized.tsv/.\/mas5_normalized\/human_hg_u133plus2_arrays_mas5_normalized.tsv/g; s/^rawData\s/print\(paste\("Total arrays: ",length\(cel_files\),sep=""\)\)\nrawData /; s/ rma\(/ mas5\(/' normalize_human_hg_u133plus2_arrays_liver.R > mas5_normalize_human_hg_u133plus2_arrays_liver.R
	mkdir -pv ./hg_u133plus2_arrays/mas5_normalized/
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --max-ppsize=500000 --file=/raw/human/mas5_normalize_human_hg_u133plus2_arrays_liver.R>> mas5_run_time_human_hg_u133plus2_arrays.txt 2>&1

# There were a lot of arrays, so I had to normalize in two rounds, so I created the script mas5_normalize_human_hg_u133plus2_arrays_liver_split_data_to2.R and used that one instead of
# mas5_normalize_human_hg_u133plus2_arrays_liver.R. In the end I didn't use the target normalize_mas5_hg_u133plus2_arrays as it is, but only modified generated R script to our needs.
normalize_mas5_hg_u133plus2_arrays_split:
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --max-ppsize=500000 --file=/raw/human/mas5_normalize_human_hg_u133plus2_arrays_liver_split_data_to2.R>> mas5_run_time_human_hg_u133plus2_arrays.txt 2>&1
	cd hg_u133plus2_arrays/mas5_normalized; \
	join -t $'\t' -j 1 --check-order <(grep -vE '^AFFX' human_hg_u133plus2_arrays_mas5_normalized_1st_half.tsv) <(grep -vE '^AFFX'  human_hg_u133plus2_arrays_mas5_normalized_2nd_half.tsv) > human_hg_u133plus2_arrays_mas5_normalized_both_parts_joined.tsv 

normalize_mas5_hg_u133_pm_arrays:
	sed -re 's/human_hg_u133_pm_arrays_normalized.tsv/.\/mas5_normalized\/human_hg_u133_pm_arrays_mas5_normalized.tsv/; s/^rawData\s/print\(paste\("Total arrays: ",length\(cel_files\),sep=""\)\)\nrawData /; s/ rma\(/ mas5\(/' normalize_human_hg_u133_pm_arrays_liver.R > mas5_normalize_human_hg_u133_pm_arrays_liver.R
#	sed -i -re 's#human/hthgu133pluspmhsensgcdf/#human/hthgu133pluspmhsensgcdf/mas5_normalized/#g' mas5_normalize_human_hg_u133_pm_arrays_liver.R
	mkdir -pv ./hg_u133_pm/mas5_normalized
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/human/mas5_normalize_human_hg_u133_pm_arrays_liver.R >> mas5_run_time_human_hg_u133_pm_arrays.txt 2>&1



# Before normalizing I have collected each CEL file under project name and then prepended to cel file name "project_"
# The next target will remove that prepended part
change_header_names_mas5:
	sed -re 's/esnats_//g; s/aanjaag_jennen_//g; s/carcinogenomics_//g; s/Carcinogenomics_extra_//g; s/magkoufopoulou_//g; s/tg_gates_//g; s/ntc_4_1_3_//g; s/ntc_1_1_8_//g' ./hg_u133plus2_arrays/mas5_normalized/human_hg_u133plus2_arrays_mas5_normalized_both_parts_joined.tsv > ./hg_u133plus2_arrays/mas5_normalized/human_hg_u133plus2_arrays_mas5_norm_new_names.tsv

average_ratio_mas5_hg_u133plus2:
	mkdir -pv average_ratio/mas5
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./hg_u133plus2_arrays/mas5_normalized/human_hg_u133plus2_arrays_mas5_norm_new_names.tsv ./ratio_info_human_arrays_hg_u133plus2.tsv ./average_ratio/mas5/human_hg_u133plus2_arrays_mas5_norm_avg_ratio.tsv|tee ./average_ratio/mas5/run_average_ratio_mas5_hg_u133plus2.log

average_ratio_mas5_hg_u133_pm:
	mkdir -pv average_ratio/mas5
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./hg_u133_pm/mas5_normalized/human_hg_u133_pm_arrays_mas5_normalized.tsv ./ratio_info_human_arrays_hg_u133_pm.tsv ./average_ratio/mas5/human_hg_u133_pm_arrays_mas5_norm_avg_ratio.tsv |tee ./average_ratio/mas5/run_average_ratio_mas5_hg_u133_pm.tsv

join_files_on_gene_id_mas5:
	/bin/bash -c "join -j 1 -t $$'\t' <(sort ./average_ratio/mas5/human_hg_u133plus2_arrays_mas5_norm_avg_ratio.tsv) <(sort ./average_ratio/mas5/human_hg_u133_pm_arrays_mas5_norm_avg_ratio.tsv) |sed -re 's/_at//g' > ./average_ratio/mas5/norm_avg_ratio_join_on_gene_ids_u133plu2_u133pm.tsv"

# TODO: Compare the resulting file has all compounds for which genotoxicity info is available
add_class_info_mas5:
	cut -f1 average_ratio/mas5/norm_avg_ratio_join_on_gene_ids_u133plu2_u133pm.tsv|grep ENSG > ./average_ratio/mas5/genes_present_in_both_platforms.tsv
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  average_ratio/mas5/norm_avg_ratio_join_on_gene_ids_u133plu2_u133pm.tsv ./average_ratio/ratio_info_human_array_platforms_u133plus2_u133pm.tsv ./average_ratio/mas5/mas5_all_data_human_array_platforms_u133plus2_u133pm.tsv ./average_ratio/mas5/genes_present_in_both_platforms.tsv|tee ./average_ratio/mas5/generation_of_all_data_human_array_platforms_u133plus2_u133pm.log

# I forgot but we NO longer use u133a_2 platform-based arrays, because they have like 11K genes, whereas other two platforms use 19K genes.
# So, we do not use this target as well, we only use two platforms.
# Anyway we mas5-normalized these arrays, but they will not be used
normalize_mas5_hg_u133a_2_arrays:
	sed -re 's/human_hg_u133a_2_arrays_normalized.tsv/.\/mas5_normalized\/human_hg_u133a_2_arrays_mas5_normalized.tsv/; s/^rawData\s/print\(paste\("Total arrays: ",length\(cel_files\),sep=""\)\)\nrawData /; s/ rma\(/ mas5\(/' normalize_human_hg_u133a_2_arrays_liver.R > mas5_normalize_human_hg_u133a_2_arrays_liver.R
	mkdir -pv ./hg_u133a_2/mas5_normalized
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/human/mas5_normalize_human_hg_u133a_2_arrays_liver.R >> mas5_run_time_human_hg_u133a_2_arrays.txt

# I forgot but we NO longer use u133a_2 platform-based arrays, because they have like 11K genes, whereas other two platforms use 19K genes.
# So, we do not use this target as well, we only use two platforms.
# Second line with the sed command is needed to get rid of extra chars in array file names, maybe it was not necessary at all, but I have already done in the ratio_info file
# I need to do it here as well.
average_ratio_mas5_hg_u133a_2_arrays:
	mkdir -pv average_ratio/mas5
	sed -re '1,1 s/\.[0-9]_[0-9]+//g' ./hg_u133a_2/mas5_normalized/human_hg_u133a_2_arrays_mas5_normalized.tsv > ./hg_u133a_2/mas5_normalized/human_hg_u133a_2_arrays_mas5_normalized_new_names.tsv
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./hg_u133a_2/mas5_normalized/human_hg_u133a_2_arrays_mas5_normalized_new_names.tsv ./ratio_info_human_arrays_hg_u133a_2.tsv ./average_ratio/mas5/human_hg_u133a_2_arrays_mas5_norm_avg_ratio.tsv|tee ./average_ratio/mas5/run_average_ratio_mas5_hg_u133a_2.log

# I forgot but we NO longer use u133a_2 platform-based arrays, because they have like 11K genes, whereas other two platforms use 19K genes.
# So, we do not use this target as well, we only use two platforms.
# The next target is needed to use only the exact set of genes that are present in all 3 platforms. Otherwise in prediction missing significant genes would be a problem.
genes_present_in_all_3_platforms_mas5:
	/bin/bash -c "join -j 1 -t $$'\t' <(sort ./average_ratio/mas5/norm_avg_ratio_join_on_gene_ids_u133plu2_u133pm.tsv) <(sort ./average_ratio/mas5/human_hg_u133a_2_arrays_mas5_norm_avg_ratio.tsv|sed -re 's/_at//g') | grep ENSG > ./average_ratio/mas5/genes_present_in_all_3_platforms.tsv "

# I forgot but we NO longer use u133a_2 platform-based arrays, because they have like 11K genes, whereas other two platforms use 19K genes.
# So, we do not use this target as well, we only use two platforms.
add_class_info_mas5_hg_u133a_2_arrays:
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  average_ratio/mas5/human_hg_u133a_2_arrays_mas5_norm_avg_ratio.tsv ./ratio_info_human_arrays_hg_u133a_2.tsv   ./average_ratio/mas5/human_hg_u133a_2_arrays_mas5_norm_avg_ratio_class_info.tsv ./average_ratio/mas5/genes_present_in_all_3_platforms.tsv |tee ./average_ratio/mas5/run_add_class_info_human_hg_u133a_2_arrays.log

# I forgot but we NO longer use u133a_2 platform-based arrays, because they have like 11K genes, whereas other two platforms use 19K genes.
# So, we do not use this target as well, we only use two platforms.
add_class_info_mas5_genes_present_in_all_3_platforms:
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  average_ratio/mas5/norm_avg_ratio_join_on_gene_ids_u133plu2_u133pm.tsv ./average_ratio/ratio_info_human_array_platforms_u133plus2_u133pm.tsv ./average_ratio/mas5/mas5_all_data_human_array_platforms_u133plus2_u133pm_genes_pres_in_3platforms.tsv ./average_ratio/mas5/genes_present_in_all_3_platforms.tsv |tee ./average_ratio/mas5/generation_of_all_data_human_array_platforms_u133plus2_u133pm_genes_pres_in_3platforms.log

# BE-Basic data was already normalized with RMA and the R script is also present there, so I will just copy them here into be_basic folder
# However, then it turned out that some samples were tested twice, so I need to re-normalize all arrays without those doubles
be_basic_normalize_mas5_data:
	echo "Task be_basic_normalize_mas5_data STARTED  at $$(date)" > ./be_basic/mas5_be_basic_normalize_data_run_time.txt; 
	sed -re 's/human_hg_u133_pm_arrays_be_basic_normalized.tsv/.\/mas5_normalized\/human_hg_u133_pm_arrays_be_basic_mas5_normalized.tsv/; s/^rawData\s/print\(paste\("Total arrays: ",length\(cel_files\),sep=""\)\)\nrawData /; s/ rma\(/ mas5\(/' ./be_basic/normalize_human_hg_u133_pm_arrays_be_basic.R > ./be_basic/mas5_normalize_human_hg_u133_pm_arrays_be_basic.R
	mkdir -pv ./be_basic/array_data/mas5_normalized
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/human/be_basic/:/be_basic/ r_base_3.4.0:array R --file=/be_basic/mas5_normalize_human_hg_u133_pm_arrays_be_basic.R >> ./be_basic/mas5_normalization_run_time_human_hg_u133_pm_arrays_be_basic.txt
	echo "Task be_basic_normalize_mas5_data FINISHED at $$(date)" >> ./be_basic/mas5_be_basic_normalize_data_run_time.txt;


# Like before I manually created and edited the file ratio file
be_basic_mas5_average_ratio:
	mkdir -pv ./be_basic/average_ratio/mas5/
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./be_basic/array_data/./mas5_normalized/human_hg_u133_pm_arrays_be_basic_mas5_normalized.tsv ./be_basic/ratio_info_for_BE_Basic_data_manually_edited_new.tsv ./be_basic/average_ratio/mas5/be_basic_mas5_normalized_avg_ratio.tsv

be_basic_mas5_class_info:
	cut -f1 ./be_basic/average_ratio/mas5/be_basic_mas5_normalized_avg_ratio.tsv|grep ENSG > ./be_basic/average_ratio/mas5/gene_names_in_be_basic_data_mas5.txt;
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  ./be_basic/average_ratio/mas5/be_basic_mas5_normalized_avg_ratio.tsv  ./be_basic/ratio_info_for_BE_Basic_data_manually_edited_new.tsv   ./be_basic/average_ratio/mas5/be_basic_mas5_normalized_avg_ratio_class_info.tsv ./be_basic/average_ratio/mas5/gene_names_in_be_basic_data_mas5.txt | tee ./be_basic/mas5_run_be_basic_normalized_avg_ratio_class_info.log


# This task is very similar to be_basic_classif_no_univar, but uses mas5 normalized data. As be_basic_separateCV_classif_univar_filter it has no univariate filtering and expression values are also unit-scaled.
be_basic_mas5_classif_no_univar:
	mkdir -pv ./be_basic/mas5_classif_no_univar/;
	echo "Task be_basic_mas5_classif_no_univar STARTED at: $$(date)" > ./be_basic/mas5_classif_no_univar/run_time.txt; 
	cat ./average_ratio/mas5/mas5_all_data_human_array_platforms_u133plus2_u133pm.tsv |sed -re 's/_at\t/\t/g; s/_at$$//' >  ./be_basic/mas5_classif_no_univar/mas5_all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv
	rsync -auvz ./be_basic/average_ratio/mas5/be_basic_mas5_normalized_avg_ratio_class_info.tsv  ./be_basic/mas5_classif_no_univar/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV_noUnivarFilter.R --args $$(pwd)/be_basic/mas5_classif_no_univar/ /share/data/openrisknet/dixa_classification/data/raw/human/be_basic/mas5_classif_no_univar/mas5_all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv $$(pwd)/be_basic/mas5_classif_no_univar/be_basic_mas5_normalized_avg_ratio_class_info.tsv|tee ./be_basic/mas5_classif_no_univar/mas5_run_be_basic_classif_no_univar.log
	echo "Task be_basic_mas5_classif_no_univar FINISHED at: $$(date)" >> ./be_basic/mas5_classif_no_univar/run_time.txt;

# Unfortunately the target be_basic_mas5_classif_no_univar didn't give good results, so I also tried with the predictomics data
predictomics_mas5_as_test_data:
	mkdir -pv predictomics_as_test
	echo "Task predictomics_mas5_as_test_data has STARTED  at: $$(date)" > predictomics_as_test/run_predictomics_mas5_as_test_data.txt
	cat ./average_ratio/mas5/mas5_all_data_human_array_platforms_u133plus2_u133pm.tsv |sed -re 's/_at\t/\t/g; s/_at$$//' >  ./predictomics_as_test/mas5_all_data_human_array_platforms_u133plus2_u133pm_gene_names_corr.tsv
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV_noUnivarFilter.R --args $$(pwd)/predictomics_as_test/ $$(pwd)/average_ratio/mas5/mas5_all_data_human_array_platforms_u133plus2_u133pm_genes_pres_in_3platforms.tsv $$(pwd)/average_ratio/mas5/human_hg_u133a_2_arrays_mas5_norm_avg_ratio_class_info.tsv |tee ./predictomics_as_test/mas5_run_predictomics_info_no_univar.log
	echo "Task predictomics_mas5_as_test_data has FINISHED at: $$(date)" >> predictomics_as_test/run_predictomics_mas5_as_test_data.txt


# Now do the classification with the MAS5-normalized data
# 10 fold cross-validation based classification after univariate filtering
mas5_separateCV_classif_univar_filter:
	mkdir -pv mas5_cross_val_classif_univar_filter/;
	echo "Task mas5_separateCV_classif_univar_filter STARTED at: $$(date)" > ./mas5_cross_val_classif_univar_filter/run_time.txt;
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_afterUnivarFilter.R --args $$(pwd)/mas5_cross_val_classif_univar_filter/ /share/data/openrisknet/dixa_classification/data/raw/human/average_ratio/mas5/mas5_all_data_human_array_platforms_u133plus2_u133pm.tsv  10|tee ./mas5_cross_val_classif_univar_filter/run.log
	echo "Task mas5_separateCV_classif_univar_filter FINISHED at: $$(date)" >> ./mas5_cross_val_classif_univar_filter/run_time.txt;


# Write a visualization part in the R script to create bw and dotplot for validation data
# Currently such plots are generated only for training data-based CV folds
