# I usually run make targets sequentially one after another
all: help

help:
	echo "Run make get_data or other targets"

get_data:
	echo "Getting GSE44088 tar file"
	wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE44nnn/GSE44088/suppl/GSE44088_RAW.tar
	echo "Getting GSE43977 tar file"
	wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE43nnn/GSE43977/suppl/GSE43977_RAW.tar
	echo "Getting GSE35058 tar file"
	wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE35nnn/GSE35058/suppl/GSE35058_RAW.tar

untar:
	mkdir GSE44088 && tar -C GSE44088 -xvf GSE44088_RAW.tar
	mkdir GSE43977 && tar -C GSE43977 -xvf GSE43977_RAW.tar
	mkdir GSE35058 && tar -C GSE35058 -xvf GSE35058_RAW.tar

gunzip:
	gunzip GSE44088/*.CEL*gz
	gunzip GSE43977/*.CEL*gz
	gunzip GSE35058/*.CEL*gz

md5sums:
	cd ./GSE44088 && md5sum *.CEL >> ./GSE44088_md5sums.txt
	cd ./GSE43977 && md5sum *.CEL >> ./GSE43977_md5sums.txt
	cd ./GSE35058 && md5sum *.CEL >> ./GSE35058_md5sums.txt

same_files:
	a=$$(tempfile -d .); b=$$(tempfile -d .); echo "$$a  $$b"; \
	cat /home/jbayjanov/projects/tgx/dixa_classification/data/md5sums/*md5sums.txt|sort|sed -re 's/\s+/#/g' > $$a; \
	find . -iname '*md5sums.txt'|xargs -I{} cat '{}'|sort|sed -re 's/\s+/#/g' > $$b; \
	join -j 1 -t '#' $$a $$b > same_CEL_files_btwn_3gse_here_and_other_mouse_files.txt; \
	rm $$a $$b

mouse_array_links:
	ln -s /ngs-data/data_storage/transcriptomics/microarray/mrna/NTC/NTC_WP4.1.1_E01 study15_ntc_wp_4.1.1_e01
	ln -s /ngs-data/data_storage/data4transport/Rieswijk/Study_PMH_miRNA_mRNA_21_compounds/data/mRNA/CEL study16_gse72081
	ln -s /ngs-data/data_storage/transcriptomics/microarray/mrna/Aanjaag/Mathijs/KM_4_compounds_archive study17_km4_compounds
	ln -s /ngs-data/data_storage/transcriptomics/microarray/mrna/Aanjaag/Mathijs/km_8_cmps_archive study18_e_mexp_2539
	ln -s /ngs-data/data_storage/transcriptomics/microarray/mrna/Aanjaag/Mathijs/E-MEXP-2636 study19_e_mexp_2636
	ln -s ./GSE44088 study20_GSE44088
	ln -s ./GSE43977 study21_GSE43977

recheck_md5sums:
	find -L . -iname "*.CEL"|grep study|xargs -I{} md5sum '{}' >> md5sums_of_all_7_mouse_studies.txt

remove_multiples_in_CEL_files:
	a=$$(tempfile -d .); b=$$(tempfile -d .); c=$$(tempfile -d .);  \
	cut -f1 -d' ' md5sums_of_all_7_mouse_studies.txt |sort|uniq -c|sort -bgr|sed -re 's/^\s*//g; s/\s+/\t/g'|awk 'BEGIN{FS="\t"}$$1>1{print($$2)}'|sort >> $$a; \
	sort md5sums_of_all_7_mouse_studies.txt  >> $$b; \
	join -j 1  $$a $$b|tr ' ' '\t' > multiple_occuring_cel_files_in_7_studies.txt; \
	python get_only_single_CEL_file.py multiple_occuring_cel_files_in_7_studies.txt single_selected_from_multiple_occuring_cel_files_in_7_studies.txt; \
	cut -f1 -d' ' md5sums_of_all_7_mouse_studies.txt |sort|uniq -c|sort -bgr|sed -re 's/^\s*//g; s/\s+/\t/g'|awk 'BEGIN{FS="\t"}$$1==1{print($$2)}'|sort >> $$c; \
	join -j 1 $$c $$b |tr ' ' '\t' >> single_selected_from_multiple_occuring_cel_files_in_7_studies.txt; \
	rm $$a $$b $$c;

collect_all_CEL_files:
	mkdir ./mg430_2_arrays
	cut -f2 single_selected_from_multiple_occuring_cel_files_in_7_studies.txt |awk 'BEGIN{FS="\t"}{a=$$1; gsub("\\(","_",a); gsub("\\)","_",a); gsub("_+","_",a);gsub("\\.\\/","mg430_2_arrays_",a);gsub("\\/","__",a);gsub("mg430_2_arrays_","./mg430_2_arrays/",a);gsub("\\(","\\\\(",$$1);gsub("\\)","\\\\)",$$1); print("rsync -auz "$$1"\t"a);}'|grep -v study20|xargs -I{} bash -c '{}'

# The next target is NOT used anymore, because apparently study GSE43977 was an in-vivo experiment.
# So, we remove and because of that now we have more changes, also name changes etc.
# After this target I will create a target normalize_mg430_2_arrays_no_GSE43977 target, which is the correct target
# DO NOT USE THE NEXT TARGET
normalize_mg430_2_arrays:
	sed -re 's/htmg430pmmmensgcdf/mouse4302mmensgcdf/g; s/mouse_GSE44088/mg430_2/g; s/ GSE44088 / all mg430_2 /; s/\/GSE44088\//\/mg430_2_arrays\//' GSE44088/normalize_mouse_GSE44088_liver.R > ./mg430_2_arrays/normalize_all_mg430_2_arrays_liver.R
	cd mg430_2_arrays; \
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/mouse/mg430_2_arrays/normalize_all_mg430_2_arrays_liver.R >> normalization_run_time.txt

# I will still use some of the results from the previous target normalize_mg430_2_arrays
# I will first just change the extension of the GSE43977 files and then also change the study ids
change_study_ids_after_GSE43977:
	cd mg430_2_arrays; \
	rename 's/\.CEL$$/.CEL_not_used/g' study21_GSE43977*.CEL; \
	rename 's/study15_ntc/study14_ntc/g' study15_ntc_wp_4.1.1_e01*CEL; \
	rename 's/study16_gse72081/study15_gse72081/g' study16_gse72081*CEL; \
	rename 's/study17_km4_compounds/study16_km4_compounds/g' study17_km4_compounds*CEL; \
	rename 's/study18_e_mexp_2539/study17_e_mexp_2539/g' study18_e_mexp_2539*CEL; \
	rename 's/study19_e_mexp_2636/study18_e_mexp_2636/g' study19_e_mexp_2636*CEL; \
	mv normalization_run_time.txt normalization_run_time_with_GSE43977.txt; \
	mv mg430_2_arrays_rma_normalized.tsv mg430_2_arrays_rma_normalized_with_GSE43977.tsv; 

# Normalize without GSE43977
normalize_mg430_2_arrays_no_GSE43977:
	cd mg430_2_arrays; \
	sed -i.bak -re 's/pattern=\"\*\.CEL\"/pattern=\"\*\.CEL$$"/; s/^rawData/print\(paste\(\"Total number of CEL files\: \"\,length\(cel_files\)\,sep\=\"\"\)\)\;\nrawData/' normalize_all_mg430_2_arrays_liver.R; \
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/mouse/mg430_2_arrays/normalize_all_mg430_2_arrays_liver.R 2>&1 >> normalization_run_time_info.txt

# The next target was NOT tested, because I just copied previous commands from history to this target
normalize_mg430_pm_arrays:
	ln -s GSE44088 mg430_pm_arrays;
	cd GSE44088; \
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/mouse/GSE44088/normalize_mouse_GSE44088_liver.R

# Most of the creation tasks of meta files are done by hand
meta_info_files:
	mkdir -pv meta_info_files;
	cp /ngs-data/data_storage/metadata/Aanjaag/Mathijs/E-MEXP-2636/E-MEXP-2636.sdrf.txt ./meta_info_files/E-MEXP-2636.sdrf.txt
	cp /ngs-data/data_storage/metadata/Aanjaag/Mathijs/km_8_cmps_archive/*8compounds.txt ./meta_info_files/
	cp /ngs-data/data_storage/metadata/Aanjaag/Mathijs/KM_4_compounds_archive/*4_compounds*txt ./meta_info_files/
	cp /ngs-data/data_storage/metadata/NTC/NTC_WP4.1.1_E01/s_Study*txt ./meta_info_files/ntc_wp4_1_1_s_Study_id.txt
	cp /ngs-data/data_storage/metadata/NTC/NTC_WP4.1.1_E01/a_study*txt ./meta_info_files/ntc_wp4_1_1_a_study.txt
	cp /ngs-data/data_storage/data4transport/Rieswijk/Study_PMH_miRNA_mRNA_21_compounds/data/mRNA/SimpleTox_compounds_unnecessary_ctrls_deleted.xlsx ./meta_info_files/study16_gse72081_SimpleTox_compounds_unnecessary_ctrls_deleted.xlsx
	wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE44nnn/GSE44088/matrix/GSE44088_series_matrix.txt.gz
	zcat ./GSE44088_series_matrix.txt.gz| grep -B 1000 Sample_data_processing  |grep -v Sample_data_processing > ./meta_info_files/meta_info_files_GSE44088.txt
	rm ./GSE44088_series_matrix.txt.gz
	wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE43nnn/GSE43977/matrix/GSE43977_series_matrix.txt.gz
	zcat GSE43977_series_matrix.txt.gz|grep -B 1000 Sample_data_processing |grep -v Sample_data_processing > ./meta_info_files/meta_info_files_GSE43977.txt
	rm GSE43977_series_matrix.txt.gz
	cut -f1,17 /ngs-data/data_storage/metadata/Aanjaag/Mathijs/km_8_cmps_archive/a_km_8compounds_transcription\ profiling_DNA\ microarray.txt > ./meta_info_files/a_KM_8compounds_id2arrayfile.txt

# Remove some of the CEL files for study15_gse72081 that had no info in the meta-info file
# These CEL files are for unneeded control files
# After this step call the target normalize_mg430_2_arrays_no_GSE43977
# I copied one of the Unneeded CTRL file as study16_km4_compounds__080618KB17J.CEL
study_gse72081_rm_ctrl_files:
	cd meta_info_files; \
	cut -f15 mouse_meta_info_file_all_experiments_update03052018.tsv|grep study15|sort|uniq|sort > study15_a.txt; \
	head -1 ../mg430_2_arrays/mg430_2_arrays_rma_normalized.tsv |tr '\t' '\n'|grep study15|sort|uniq|sort > study15_b.txt; \
	diff  study15_a.txt study15_b.txt |grep '>'|sed -re 's/^\s*>\s*//g' > ../mg430_2_arrays/unneeded_ctrls_study15_gse72081.txt ; \
	rm study15_a.txt study15_b.txt ; \
	cd ../mg430_2_arrays/ ; \
	for i in $$(cat unneeded_ctrls_study15_gse72081.txt); do mv $${i} $${i}_unneeded_CTRLS; done ;\
	mv study15_gse72081__080618KB7J.CEL_unneeded_CTRLS study15_gse72081__080618KB7J.CEL;
	rsync -auvz mg430_2_arrays/study15_gse72081__080618KB17J.CEL_unneeded_CTRLS ./mg430_2_arrays/study16_km4_compounds__080618KB17J.CEL
#	rsync -auvz mg430_2_arrays/study15_gse72081__080618KB17J.CEL_unneeded_CTRLS ./mg430_2_arrays/study16_km4_compounds__080618KB17J.CEL


# I maunally created the file ./meta_info_files/mouse_meta_info_file_all_experiments_update03052018.tsv
average_ratio_for_mg430_2_arrays:
	mkdir -pv average_ratio
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./mg430_2_arrays/mg430_2_arrays_rma_normalized.tsv ./meta_info_files/mouse_meta_info_file_all_experiments_update03052018.tsv ./average_ratio/mouse_mg430_2_arrays_normalized_avg_ratio.tsv

average_ratio_for_mg430_pm_arrays:
	cd mg430_pm_arrays ; \
	sed -re '1 s/\tGSM/\tstudy19_GSM/g' mouse_GSE44088_arrays_rma_normalized.tsv > mouse_GSE44088_arrays_rma_normalized_studyHeader.tsv ;
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./mg430_pm_arrays/mouse_GSE44088_arrays_rma_normalized_studyHeader.tsv ./meta_info_files/mouse_meta_info_file_all_experiments_update03052018.tsv ./average_ratio/mouse_mg430_pm_arrays_normalized_avg_ratio.tsv


join_files_on_gene_id:
	cd average_ratio; \
	awk 'NR==1{print};NR>1 && $$1 ~ /ENSMUSG/{print}' mouse_mg430_2_arrays_normalized_avg_ratio.tsv|sed -re '1 s/^\t/99999\t/'| sort -sd -k 1 > mouse_mg430_2_arrays_normalized_avg_ratio_sorted.tsv; \
	awk 'NR==1{print};NR>1 && $$1 ~ /ENSMUSG/{print}' mouse_mg430_pm_arrays_normalized_avg_ratio.tsv|sed -re '1 s/^\t/99999\t/'|sort -sd -k 1 > mouse_mg430_pm_arrays_normalized_avg_ratio_sorted.tsv; \
	/bin/bash -c "join  -j 1 -t $$'\t' mouse_mg430_2_arrays_normalized_avg_ratio_sorted.tsv mouse_mg430_pm_arrays_normalized_avg_ratio_sorted.tsv |sed -re 's/_at//g'|sed -re '1 s/99999\t/\t/' > normalized_join_on_gene_ids_mouse_both_arrays.tsv"; \
	rm mouse_mg430_2_arrays_normalized_avg_ratio_sorted.tsv mouse_mg430_pm_arrays_normalized_avg_ratio_sorted.tsv


### CHECK this step and maybe also the previous step, then try if everything is OK
add_class_info:
	cut -f1 ./average_ratio/normalized_join_on_gene_ids_mouse_both_arrays.tsv |grep ENSMUSG  > ./average_ratio/gene_names_in_all_2_mouse_arrays.txt;
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  ./average_ratio/normalized_join_on_gene_ids_mouse_both_arrays.tsv ./meta_info_files/mouse_meta_info_file_all_experiments_update03052018.tsv  ./average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv   ./average_ratio/gene_names_in_all_2_mouse_arrays.txt |tee ./average_ratio/run_avg_ratio_class_info.log

split_train_test:
	cd average_ratio; \
	head -1 class_info_join_on_gene_ids_mouse_both_arrays.tsv  > training_data_mouse_both_arrays.tsv; \
	head -1 class_info_join_on_gene_ids_mouse_both_arrays.tsv > test_data_mouse_both_arrays.tsv; \
	awk 'NR>1{a=rand(); if(a<=0.2){print >> "test_data_mouse_both_arrays.tsv";}else{print >> "training_data_mouse_both_arrays.tsv";}}' class_info_join_on_gene_ids_mouse_both_arrays.tsv

run_classification:
	mkdir -pv classification/run1;
	rsync -auz average_ratio/training_data_mouse_both_arrays.tsv ./classification/
	rsync -auz average_ratio/test_data_mouse_both_arrays.tsv  ./classification/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret.R --args $$(pwd)/classification/run1/ /share/data/openrisknet/dixa_classification/data/raw/mouse/classification/training_data_mouse_both_arrays.tsv /share/data/openrisknet/dixa_classification/data/raw/mouse/classification/test_data_mouse_both_arrays.tsv|tee classification/run1.log

# 10 fold cross-validation based classification
separateCV_classification:
	mkdir -pv cross_val_classification/;
	echo "Task separateCV_classification STARTED at: $$(date)" > ./cross_val_classification/run_time.txt;
	rsync -auz ./average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv ./cross_val_classification/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV.R --args $$(pwd)/cross_val_classification/ /share/data/openrisknet/dixa_classification/data/raw/mouse/cross_val_classification/class_info_join_on_gene_ids_mouse_both_arrays.tsv 10|tee ./cross_val_classification/run.log
	echo "Task separateCV_classification FINISHED at: $$(date)" >> ./cross_val_classification/run_time.txt;

# 10 fold cross-validation based classification after doing univariate filtering
separateCV_classif_univar_filter:
	mkdir -pv cross_val_classif_univar_filter/;
	echo "Task  STARTED at: $$(date)" > ./cross_val_classif_univar_filter/run_time.txt;
	rsync -auz ./average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv ./cross_val_classif_univar_filter/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_afterUnivarFilter.R --args $$(pwd)/cross_val_classif_univar_filter/ /share/data/openrisknet/dixa_classification/data/raw/mouse/cross_val_classif_univar_filter/class_info_join_on_gene_ids_mouse_both_arrays.tsv 10|tee ./cross_val_classif_univar_filter/run.log
	echo "Task separateCV_classif_univar_filter FINISHED at: $$(date)" >> ./cross_val_classif_univar_filter/run_time.txt;

# 10 fold cross-validation based classification for selected set of genes, which were based on 10-fold cross-validation univariate filtering of the target separateCV_classif_univar_filter
selected_genes_cross_val:
	cd cross_val_classif_univar_filter/ && ./select_best_features.sh 75 && cd ../
	mkdir -pv selected_genes_cross_val/;
	echo "Task selected_genes_cross_val STARTED at: $$(date)" > ./selected_genes_cross_val/run_time.txt;
#	rsync -auz ./average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv ./selected_genes_cross_val/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_selectedGenesOnly.R --args $$(pwd)/selected_genes_cross_val/ /share/data/openrisknet/dixa_classification/data/raw/mouse/cross_val_classif_univar_filter/class_info_join_on_gene_ids_mouse_both_arrays.tsv 10 $$(pwd)/cross_val_classif_univar_filter/significant_variables.txt|tee ./selected_genes_cross_val/run.log
	echo "Task selected_genes_cross_val FINISHED at: $$(date)" >> ./selected_genes_cross_val/run_time.txt;

# 10 fold cross-validation based classification for selected set of genes, which were based on 10-fold cross-validation univariate filtering of the target separateCV_classif_univar_filter
# Same as the target selected_genes_cross_val, but it is the 2nd round so uses the output of that target (selected_genes_cross_val)
selected_genes_cross_val_round2:
	cp cross_val_classif_univar_filter/select_best_features.sh ./selected_genes_cross_val/ && cd selected_genes_cross_val/ && ./select_best_features.sh 75 && cd ../
	mkdir -pv selected_genes_cross_val_round2/;
	echo "Task selected_genes_cross_val_round2 STARTED at: $$(date)" > ./selected_genes_cross_val_round2/run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_selectedGenesOnly.R --args $$(pwd)/selected_genes_cross_val_round2/ /share/data/openrisknet/dixa_classification/data/raw/mouse/cross_val_classif_univar_filter/class_info_join_on_gene_ids_mouse_both_arrays.tsv 10 $$(pwd)/selected_genes_cross_val/significant_variables.txt|tee ./selected_genes_cross_val_round2/run.log
	echo "Task selected_genes_cross_val_round2 FINISHED at: $$(date)" >> ./selected_genes_cross_val_round2/run_time.txt;

# 10 fold cross-validation based classification for selected set of genes, which were based on 10-fold cross-validation univariate filtering of the target separateCV_classif_univar_filter
# This target is almost identical to the previous target selected_genes_cross_val, except it will be used by the next target iterative_gene_selection to run gene selection in more or less an isolated folder
# Here an isolated folder is just a separate folder, so this target will not create a new directory. It will just work in a directory, where it was called.
select_genes_cross_val_isolated:
#	cd cross_val_classif_univar_filter/ && ./select_best_features.sh 75 && cd ../
#	mkdir -pv selected_genes_cross_val/;
	echo "Task selected_genes_cross_val_isolated STARTED at: $$(date)" > run_time.txt;
#	rsync -auz ./average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv ./selected_genes_cross_val/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_selectedGenesOnly.R --args $$(pwd)/ /share/data/openrisknet/dixa_classification/data/raw/mouse/cross_val_classif_univar_filter/class_info_join_on_gene_ids_mouse_both_arrays.tsv 10 $$(pwd)/../significant_variables.txt|tee ./run.log
	echo "Task selected_genes_cross_val_isolated FINISHED at: $$(date)" >> ./run_time.txt;

# The following target is an iterative process of removing genes based on the decrease in average accuracy, average sensitivity and average specificity
# If after removing insignificant genes average accucary doesn't decrease more than X% (X=10, here) then continue removing the genes.
# Here the baseline average accuracy, sensitivity and specificity are taken from the first round of gene selection
iterative_gene_selection:
	mkdir -pv iterative_gene_selection
#	The file selected_genes_cross_val/significant_variables.txt is generated by select_best_features.sh
	cp cross_val_classif_univar_filter/significant_variables.txt ./iterative_gene_selection/significant_variables_base.txt
	cp ./cross_val_classif_univar_filter/select_best_features.sh ./iterative_gene_selection/
	./calculate_alg_perf.sh algorithms_performance_before_gene_selection.txt ./cross_val_classif_univar_filter/
	cp ./cross_val_classif_univar_filter/algorithms_performance_before_gene_selection.txt ./iterative_gene_selection/
	cd ./iterative_gene_selection/; \
	ln -s significant_variables_base.txt significant_variables.txt; \
	echo "Task iterative_gene_selection STARTED at: $$(date)" > run_time.txt; \
	for r in $$(seq 1 20); do echo "STARTED run $${r} at: $$(date)" >> run_time.txt; mkdir run_$${r}; cp ../Makefile ./run_$${r}; cd ./run_$${r}; make select_genes_cross_val_isolated; cp ../../calculate_alg_perf.sh .; ./calculate_alg_perf.sh alg_perf_gene_selection_run_$${r}.txt; cp ../select_best_features.sh .;  ./select_best_features.sh 75; cd ../; a=$$(../find_avg_perf_diff.sh ./algorithms_performace_before_gene_selection.txt ./run_$${r}/alg_perf_gene_selection_run_$${r}.txt avg_perf_diff_base_vs_run_$${r}.txt 0.1); if(($$a==1)); then echo "Gene selection decreased average performance metric at least 10%. So stopping gene selection at run $${r}"; break; fi;echo "FINISHED run $${r} at: $$(date)" >> run_time.txt; b=$$(cmp significant_variables.txt run_$${r}/significant_variables.txt); if [ "$b" == "" ]; then echo "No new feature was filtered between two steps, so exiting now at the finish of step $${r}"; break; fi; rm significant_variables.txt; ln -s ./run_$${r}/significant_variables.txt .; done; \
	echo "Task iterative_gene_selection FINISHED at: $$(date)" >> run_time.txt;


######
# Orthology part
# Using the orthologs that are common among all 3 species classify the data again
######

orthologs_separateCV:
	mkdir -pv ./classification/orthologs_cv
	echo "Task orthologs_separateCV STARTED at: $$(date)" > ./classification/orthologs_cv/run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_common_orthologs_withSeparateCV.R --args $$(pwd)/classification/orthologs_cv/ /share/data/openrisknet/dixa_classification/data/raw/mouse/average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv $$(pwd)/../human/orthologs/common_one2one_orthologs_human_mouse_rat.tsv 2|tee ./classification/orthologs_cv/run.log
	echo "Task orthologs_separateCV FINISHED at: $$(date)" >> ./classification/orthologs_cv/run_time.txt;



# Write a visualization part in the R script to create bw and dotplot for validation data
# Currently such plots are generated only for training data-based CV folds
