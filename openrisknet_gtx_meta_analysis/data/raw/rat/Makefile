# I usually run make targets sequentially one after another
all: help

help:
	echo "Run make get_data or other targets, usually run one after another sequentially"

# The last two lines of this target is done after running the make target
get_tg_gates_data:
	echo "Getting TG-Gates Rat in-vitro data"
	mkdir tg_gates
	cd tg_gates; \
	wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/TG-Gates/archive/DIXA-005/s_Rat_hepatocyte.txt; \
	wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/TG-Gates/archive/DIXA-005/a_rat_hepatocyte_transcription%20profiling_DNA%20microarray.txt; \
#	wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/TG-Gates/archive/DIXA-008/s_Rat_Liver.txt ; 
#	wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/TG-Gates/archive/DIXA-008/a_rat_liver_transcription%20profiling_DNA%20microarray.txt; 
	dos2unix -F *.txt; \
	rename 's/\s+/_/g' a_rat_liver_transcription\ profiling_DNA\ microarray.txt ; \
	wget -m ftp://ftp.biosciencedbc.jp/archive/open-tggates/LATEST/Rat/in_vitro/; \
	echo "mv ftp.biosciencedbc.jp/archive/open-tggates/LATEST/Rat/in_vitro in_vitro"; \
	echo "rm -rf ftp.biosciencedbc.jp/"

unzip_tg_gates:
	cd tg_gates/in_vitro; \
	for i in $$(ls *.zip); do  echo "Unzipping $$i"; unzip $$i; done

link_to_carcinogenomics_rat_data:
	grep -i rattus ../carcinogenomics/s_Liver.txt |grep -v '_W_'|grep -v '_M_'|cut -f1|sort|tr -d '"'|xargs -I{} find ../carcinogenomics/liver/micro/ -iname '{}.CEL'|sed -re 's/^/..\//g' > carcinogenomics_rat_cel_files.txt
	mkdir carcinogenomics
	cat carcinogenomics_rat_cel_files.txt|xargs -I{} ln -s '{}' ./carcinogenomics/
	cd ./carcinogenomics && ln -s ../../carcinogenomics/s_Liver.txt .
	cd ./carcinogenomics && ln -s ../../carcinogenomics/a_liver_transcription_profiling_DNA_microarray.txt .
	cd ./carcinogenomics && dos2unix -F *.txt

link_to_drugmatrix_rat_data:
	cut -f2 ../drugmatrix/hepatocyte/s_Hepatocyte.txt |grep -v 'Characteristics'|xargs -I{} find ../drugmatrix/hepatocyte/ -iname '{}.CEL'|sed -re 's/^/..\//g' > drugmatrix_rat_cel_files.txt
	mkdir drugmatrix
	cat drugmatrix_rat_cel_files.txt|xargs -I{} ln -s '{}' ./drugmatrix/
	cd ./drugmatrix && ln -s ../../drugmatrix/hepatocyte/s_Hepatocyte.txt .
	cd ./drugmatrix && ln -s ../../drugmatrix/hepatocyte/a_hepatocyte_transcription_profiling_DNA_microarray.txt .
	cd drugmatrix && dos2unix -F *.txt

md5sums:
	find ./carcinogenomics/ -iname '*.CEL'|xargs -I{} md5sum '{}' >> ./carcinogenomics/carcinogenomics_cel_files_md5sums.txt
	find ./drugmatrix/ -iname '*.CEL'|xargs -I{} md5sum '{}' >> ./drugmatrix/drugmatrix_cel_files_md5sums.txt
	find ./tg_gates/ -iname '*.CEL'|xargs -I{} md5sum '{}' >> ./tg_gates/tg_gates_cel_files_md5sums.txt

check_md5sums_similarity:
	a=$$(tempfile -d .); b=$$(tempfile -d .); \
	cat carcinogenomics/carcinogenomics_cel_files_md5sums.txt drugmatrix/drugmatrix_cel_files_md5sums.txt |cut -f1 -d' '|sort > $$a; \
	sort tg_gates/tg_gates_cel_files_md5sums.txt|cut -f1 -d' ' > $$b; \
	join -j 1 $$a $$b > rat_same_cel_files.txt; \
	cut -f1 -d' ' carcinogenomics/carcinogenomics_cel_files_md5sums.txt |sort > $$a; \
	cut -f1 -d' ' drugmatrix/drugmatrix_cel_files_md5sums.txt |sort > $$b; \
	join -j 1 $$a $$b >> rat_same_cel_files.txt; \
	rm $$a $$b; 

collect_all_cel_files:
	mkdir all_rat_cel_files_tmp
	find ./carcinogenomics/ -iname '*.CEL' |awk '{a=$$1; gsub(".+/","",a); print("rsync -auz "$$1" ./all_rat_cel_files_tmp/carcinogenomics_"a);}'|xargs -I{} bash -c '{}'
	find ./drugmatrix/ -iname '*.CEL' |awk '{a=$$1; gsub(".+/","",a); print("rsync -auz "$$1" ./all_rat_cel_files_tmp/drugmatrix_"a);}'|xargs -I{} bash -c '{}'
	find ./tg_gates/ -iname '*.CEL' |awk '{a=$$1; gsub(".+/","",a); print("rsync -auz "$$1" ./all_rat_cel_files_tmp/tg_gates_"a);}'|xargs -I{} bash -c '{}'

normalize_all_rat_arrays:
	sed -re 's/mouse4302mmensgcdf/rat2302rnensgcdf/g; s/mouse\/mg430_2_arrays\//rat\/all_rat_cel_files_tmp\//g; s/mg430_2_arrays_rma_normalized/all_rat_cel_files_rma_normalized/; s/ mg430_2 mouse CEL / rat CEL /' ../mouse/mg430_2_arrays/normalize_all_mg430_2_arrays_liver.R > normalize_all_rat_arrays_liver.R
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/rat/normalize_all_rat_arrays_liver.R >> normalization_run_time_all_rat_cel_files.txt

classify_info_tg_gates:
	./select_classif_info_for_tg_gates.sh

classify_info_drugmatrix:
	select_classif_info_for_drugmatrix.sh

classify_info_carcinogenomics:
	select_classif_info_for_carcinogenomics.sh

# After this target I wanted to manually create control_file and final_array_name columns, but there are many rows it is nearly impossible.
# So, I need to program it
ratio_info_for_all_3_projects:
	cp classif_info_for_tg_gates_rat_Liver.tsv ratio_info_for_all_3_projects.tsv
	awk 'NR>1' ./classif_info_for_carcinogenomics_rat_Liver.tsv >> ratio_info_for_all_3_projects.tsv
	awk 'NR>1' ./classif_info_for_drugmatrix_rat_Liver.tsv >> ratio_info_for_all_3_projects.tsv


# Then I maunally edited the file ratio_info_for_all_3_projects.tsv and got ratio_info_for_all_3_projects_manually_edited.tsv
average_ratio_for_all_3_projects:
	mkdir average_ratio
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args  ./all_rat_cel_files_tmp/all_rat_cel_files_rma_normalized.tsv  ./ratio_info_for_all_3_projects_manually_edited.tsv ./average_ratio/rat_all_3_projects_normalized_avg_ratio.tsv

### CHECK this step and maybe also the previous step, then try if everything is OK
add_class_info:
	cut -f1 ./average_ratio/rat_all_3_projects_normalized_avg_ratio.tsv|grep ENSR > ./average_ratio/gene_names_in_rat_all_3_projects.txt;
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  ./average_ratio/rat_all_3_projects_normalized_avg_ratio.tsv ./ratio_info_for_all_3_projects_manually_edited.tsv ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv  ./average_ratio/gene_names_in_rat_all_3_projects.txt |tee ./average_ratio/run_rat_all_3_projects_normalized_avg_ratio_class_info.log

split_train_test:
	cd average_ratio; \
	head -1 rat_all_3_projects_normalized_avg_ratio_class_info.tsv  > training_data_rat_all_3_projects.tsv; \
	head -1 rat_all_3_projects_normalized_avg_ratio_class_info.tsv > test_data_rat_all_3_projects.tsv; \
	awk 'NR>1{a=rand(); if(a<=0.2){print >> "test_data_rat_all_3_projects.tsv";}else{print >> "training_data_rat_all_3_projects.tsv";}}' rat_all_3_projects_normalized_avg_ratio_class_info.tsv

run_classification:
	mkdir -pv classification/run1;
	echo "Task run_classification STARTED at: $$(date)" > ./classification/run_time.txt;
	rsync -auz average_ratio/training_data_rat_all_3_projects.tsv ./classification/
	rsync -auz average_ratio/test_data_rat_all_3_projects.tsv  ./classification/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret.R --args $$(pwd)/classification/run1/ /share/data/openrisknet/dixa_classification/data/raw/rat/classification/training_data_rat_all_3_projects.tsv /share/data/openrisknet/dixa_classification/data/raw/rat/classification/test_data_rat_all_3_projects.tsv|tee classification/run1.log
	echo "Task run_classification FINISHED at: $$(date)" >> ./classification/run_time.txt;

# Run the classification for 10 times without caret doing CV on training data
# Make equal number of GTX cases for each training set and also NGTX cases for each training case. Same applies to the test data as well.
# Number of samples need to be same for all training sets, and also for test sets
cv10_classification:
	mkdir -pv cv10_classification/;
	cd cv10_classification; \
	for i in $$(seq 1 10); do \
          head -1 ../average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv  > training_data_rat_all_3_projects.tsv; \
          head -1 ../average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv > test_data_rat_all_3_projects.tsv; \
          awk 'BEGIN{srand()};NR>1{a=rand(); if(a<=0.2){print >> "test_data_rat_all_3_projects.tsv";}else{print >> "training_data_rat_all_3_projects.tsv";}}' ../average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv; \
          mkdir cvrun$${i}; \
          R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV.R --args $$(pwd)/cvrun$${i}/ $$(pwd)/training_data_rat_all_3_projects.tsv $$(pwd)/test_data_rat_all_3_projects.tsv|tee cvrun$${i}.log; \
          cut -f1-2 training_data_rat_all_3_projects.tsv > training_data_rat_all_3_projects_run$${i}.tsv; \
          cut -f1-2 test_data_rat_all_3_projects.tsv > test_data_rat_all_3_projects_run$${i}.tsv; \
          rm training_data_rat_all_3_projects.tsv test_data_rat_all_3_projects.tsv; \
        done; \

# Rules cv10_classification and separateCV_classification are almost identical, the only difference is that the rule separateCV_classification uses caret's own data resampling methods and therefore keeps proportion of GTX/NGTX same or very similar across all training and validation data sets. For that reason it is advised to use this rule from now on.
separateCV_classification:
	mkdir -pv cross_val_classification/;
	echo "Task separateCV_classification STARTED at: $$(date)" > ./cross_val_classification/run_time.txt;
	rsync -auz ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv ./cross_val_classification/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV.R --args $$(pwd)/cross_val_classification/ /share/data/openrisknet/dixa_classification/data/raw/rat/cross_val_classification/rat_all_3_projects_normalized_avg_ratio_class_info.tsv 10|tee ./cross_val_classification/run.log
	echo "Task separateCV_classification FINISHED at: $$(date)" >> ./cross_val_classification/run_time.txt;

separateCV_classif_univar_filter:
	mkdir -pv cross_val_classif_univar_filter/;
	echo "Task separateCV_classif_univar_filter STARTED at: $$(date)" > ./cross_val_classif_univar_filter/run_time.txt; 
	rsync -auz ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv ./cross_val_classif_univar_filter/
	R -q --max-ppsize=500000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_afterUnivarFilter.R --args $$(pwd)/cross_val_classif_univar_filter/ /share/data/openrisknet/dixa_classification/data/raw/rat/cross_val_classif_univar_filter/rat_all_3_projects_normalized_avg_ratio_class_info.tsv 10|tee ./cross_val_classif_univar_filter/run.log
	echo "Task separateCV_classif_univar_filter FINISHED at: $$(date)" >> ./cross_val_classif_univar_filter/run_time.txt;


# 10 fold cross-validation based classification for selected set of genes, which were based on 10-fold cross-validation univariate filtering of the target separateCV_classif_univar_filter
selected_genes_cross_val:
	cp ../mouse/cross_val_classif_univar_filter/select_best_features.sh ./cross_val_classif_univar_filter/
	cd cross_val_classif_univar_filter/ && ./select_best_features.sh 75 && cd ../
	mkdir -pv selected_genes_cross_val/;
	echo "Task selected_genes_cross_val STARTED at: $$(date)" > ./selected_genes_cross_val/run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_selectedGenesOnly.R --args $$(pwd)/selected_genes_cross_val/ /share/data/openrisknet/dixa_classification/data/raw/rat/cross_val_classif_univar_filter/rat_all_3_projects_normalized_avg_ratio_class_info.tsv 10 $$(pwd)/cross_val_classif_univar_filter/significant_variables.txt|tee ./selected_genes_cross_val/run.log
	echo "Task selected_genes_cross_val FINISHED at: $$(date)" >> ./selected_genes_cross_val/run_time.txt;

# This is a very specific case of the selected 60 genes. This should NOT be used for general case of feature selection
selected_genes_separateCV_classif:
	mkdir -pv selected_genes_cross_val_classif/;
	rsync -auz ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv ./selected_genes_cross_val_classif/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_60genes_withSeparateCV.R --args $$(pwd)/selected_genes_cross_val_classif/ /share/data/openrisknet/dixa_classification/data/raw/rat/cross_val_classification/rat_all_3_projects_normalized_avg_ratio_class_info.tsv $$(pwd)/60_selected_genes.txt|tee ./selected_genes_cross_val_classif/run.log


# 10 fold cross-validation based classification for selected set of genes, which were based on 10-fold cross-validation univariate filtering of the target separateCV_classif_univar_filter
# This target is almost identical to the previous target selected_genes_cross_val, except it will be used by the next target iterative_gene_selection to run gene selection in more or less an isolated folder
# Here an isolated folder is just a separate folder, so this target will not create a new directory. It will just work in a directory, where it was called.
select_genes_cross_val_isolated:
	echo "Task selected_genes_cross_val_isolated STARTED at: $$(date)" > run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV_selectedGenesOnly.R --args $$(pwd)/ /share/data/openrisknet/dixa_classification/data/raw/rat/cross_val_classif_univar_filter/rat_all_3_projects_normalized_avg_ratio_class_info.tsv 10 $$(pwd)/../significant_variables.txt|tee ./run.log
	echo "Task selected_genes_cross_val_isolated FINISHED at: $$(date)" >> ./run_time.txt;

# The following target is an iterative process of removing genes based on the decrease in average accuracy, average sensitivity and average specificity
# If after removing insignificant genes average accucary doesn't decrease more than X% (X=10, here) then continue removing the genes.
# Here the baseline average accuracy, sensitivity and specificity are taken from the first round of gene selection
iterative_gene_selection:
	cp ../mouse/calculate_alg_perf.sh . && cp ../mouse/find_avg_perf_diff.sh .
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


######
# Orthology part
# Using the orthologs that are common among all 3 species classify the data again
######

orthologs_separateCV:
	mkdir -pv orthologs_cv
	echo "Task orthologs_separateCV STARTED at: $$(date)" > ./orthologs_cv/run_time.txt;
	ln -s  $$(pwd)/average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv ./orthologs_cv/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_common_orthologs_withSeparateCV.R --args $$(pwd)/orthologs_cv/ /share/data/openrisknet/dixa_classification/data/raw/rat/orthologs_cv/rat_all_3_projects_normalized_avg_ratio_class_info.tsv $$(pwd)/../human/orthologs/common_one2one_orthologs_human_mouse_rat.tsv 3|tee ./orthologs_cv/run.log
	echo "Task orthologs_separateCV FINISHED at: $$(date)" >> ./orthologs_cv/run_time.txt;


orthologs_all3speciesCV:
	mkdir -pv classification/orthologs_all3species
	echo "Task orthologs_separateCV STARTED at: $$(date)" > classification/orthologs_all3species/run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_common_orthologs_all3species_CV.R --args $$(pwd)/classification/orthologs_all3species/ /share/data/openrisknet/dixa_classification/data/raw/human/average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv /share/data/openrisknet/dixa_classification/data/raw/rat/orthologs_cv/rat_all_3_projects_normalized_avg_ratio_class_info.tsv  /share/data/openrisknet/dixa_classification/data/raw/mouse/average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv $$(pwd)/../human/orthologs/common_one2one_orthologs_human_mouse_rat.tsv|tee classification/orthologs_all3species/run.log
	echo "Task orthologs_separateCV FINISHED at: $$(date)" >> classification/orthologs_all3species/run_time.txt;


orthologs_all3speciesCV_univarFilter:
	mkdir -pv classification/orthologs_all3species_univarFilter
	echo "Task orthologs_separateCV_univarFilter STARTED at: $$(date)" > classification/orthologs_all3species_univarFilter/run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_common_orthologs_all3species_CV_univarFilter.R --args $$(pwd)/classification/orthologs_all3species_univarFilter/ /share/data/openrisknet/dixa_classification/data/raw/human/average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv /share/data/openrisknet/dixa_classification/data/raw/rat/orthologs_cv/rat_all_3_projects_normalized_avg_ratio_class_info.tsv  /share/data/openrisknet/dixa_classification/data/raw/mouse/average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv $$(pwd)/../human/orthologs/common_one2one_orthologs_human_mouse_rat.tsv 10|tee classification/orthologs_all3species_univarFilter/run.log
	echo "Task orthologs_separateCV_univarFilter FINISHED at: $$(date)" >> classification/orthologs_all3species_univarFilter/run_time.txt;

# 10 fold cross-validation based classification for selected set of genes, which were based on 10-fold cross-validation univariate filtering of the target separateCV_classif_univar_filter
# This target is almost identical to the previous target selected_genes_cross_val, except it will be used by the next target iterative_gene_selection to run gene selection in more or less an isolated folder
# Here an isolated folder is just a separate folder, so this target will not create a new directory. It will just work in a directory, where it was called.
# The next target is same as select_genes_cross_val_isolated, but applied to orthologs of all 3 species
select_genes_cross_val_isolated_orth3sp:
	echo "Task selected_genes_cross_val_isolated_orth3sp STARTED at: $$(date)" > run_time.txt;
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_common_orthologs_all3speciesCV_selectedGenesOnly.R --args $$(pwd)/ /share/data/openrisknet/dixa_classification/data/raw/human/average_ratio/all_data_human_array_platforms_u133plus2_u133pm.tsv /share/data/openrisknet/dixa_classification/data/raw/rat/orthologs_cv/rat_all_3_projects_normalized_avg_ratio_class_info.tsv  /share/data/openrisknet/dixa_classification/data/raw/mouse/average_ratio/class_info_join_on_gene_ids_mouse_both_arrays.tsv /share/data/openrisknet/dixa_classification/data/raw/human/orthologs/common_one2one_orthologs_human_mouse_rat.tsv 10 $$(pwd)/../significant_variables.txt|tee ./run.log
	echo "Task selected_genes_cross_val_isolated_orth3sp FINISHED at: $$(date)" >> ./run_time.txt;


orthologs_all3speciesCV_iterGeneSelect:
	mkdir -pv ./classification/orthologs_all3speciesCV_iterGeneSelect
	echo "Task orthologs_all3speciesCV_iterGeneSelect STARTED at: $$(date)" > ./classification/orthologs_all3speciesCV_iterGeneSelect/run_time.txt;
	cp ../mouse/calculate_alg_perf.sh . && cp ../mouse/find_avg_perf_diff.sh .
	cp ../mouse/calculate_alg_perf.sh ./classification/orthologs_all3speciesCV_iterGeneSelect/ && cp ../mouse/find_avg_perf_diff.sh ./classification/orthologs_all3speciesCV_iterGeneSelect/
#	The file selected_genes_cross_val/significant_variables.txt is generated by select_best_features.sh
	cp ./orthologs_cv/select_best_features.sh ./classification/orthologs_all3species_univarFilter/
	cd  ./classification/orthologs_all3species_univarFilter && ./select_best_features.sh 75
	cp ./classification/orthologs_all3species_univarFilter/significant_variables.txt  ./classification/orthologs_all3speciesCV_iterGeneSelect/significant_variables_base.txt
	cp ./orthologs_cv/select_best_features.sh ./classification/orthologs_all3speciesCV_iterGeneSelect/
	./calculate_alg_perf.sh algorithms_performance_before_gene_selection.txt ./classification/orthologs_all3species_univarFilter/
	cp ./classification/orthologs_all3species_univarFilter/algorithms_performance_before_gene_selection.txt ./classification/orthologs_all3speciesCV_iterGeneSelect
	cd ./classification/orthologs_all3speciesCV_iterGeneSelect; \
	ln -s significant_variables_base.txt significant_variables.txt; \
	for r in $$(seq 1 10); do echo "STARTED run $${r} at: $$(date)" >> run_time.txt; mkdir run_$${r}; cp ../../Makefile ./run_$${r}; cd ./run_$${r}; make select_genes_cross_val_isolated_orth3sp; cp ../calculate_alg_perf.sh .; ./calculate_alg_perf.sh alg_perf_gene_selection_run_$${r}.txt; cp ../select_best_features.sh .;  ./select_best_features.sh 75; cd ../; a=$$(../find_avg_perf_diff.sh ./algorithms_performace_before_gene_selection.txt ./run_$${r}/alg_perf_gene_selection_run_$${r}.txt avg_perf_diff_base_vs_run_$${r}.txt 0.1); if(($$a==1)); then echo "Gene selection decreased average performance metric at least 10%. So stopping gene selection at run $${r}"; break; fi;echo "FINISHED run $${r} at: $$(date)" >> run_time.txt; b=$$(cmp significant_variables.txt run_$${r}/significant_variables.txt); if [ "$$b" == "" ]; then echo "No new feature was filtered between two steps, so exiting now at the finish of step $${r}"; break; fi; rm significant_variables.txt; ln -s ./run_$${r}/significant_variables.txt .; done; \
	echo "Task orthologs_all3speciesCV_iterGeneSelect FINISHED at: $$(date)" >> run_time.txt

# This target we are not using, because I already created and downloaded these files
# I have also copied GSE119933_compounds_custom.* files from my laptop, which are corrected by us.
# Original phenotypes file is here ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE119nnn/GSE119933/suppl/GSE119933%5Fcompounds%2Exlsx
# I have also downloaded the table S2 from the paper's suppementary data section and then modified version is GSE119933_table_S2.tsv
# Also discard time point zero T0 files
download_nrw_data:
	mkdir nrw_data
	cd nrw_data/; \
	wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE119nnn/GSE119933/suppl/GSE119933_RAW.tar; \
	wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE119nnn/GSE119933/matrix/GSE119933_series_matrix.txt.gz; \
	gunzip GSE119933_series_matrix.txt.gz; \
	wget ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE119nnn/GSE119933/soft/GSE119933_family.soft.gz; \
	gunzip GSE119933_family.soft.gz; \
	./id2title.sh; \
	mkdir raw_data; \
	mv GSE119933_RAW.tar raw_data/; \
	cd raw_data/; \
	tar -xvf GSE119933_RAW.tar; \
	mv GSE119933_RAW.tar ../ && gunzip *.gz; \
	./rename_cel_files.sh; \
	rename 's/.CEL/.CELdiscard/' *_T0_*CEL; \
	mkdir dicard && mv *CELdiscard ./discard/;\
	cd ../; 

normalize_NRW_rat_arrays:
	sed -re 's#/rat/all_rat_cel_files_tmp/#/rat/nrw_data/raw_data/#g; s#all_rat_cel_files_rma_normalized#all_nrw_rat_cel_files_rma_normalized#; s# rat CEL # NRW (except T0 ) rat CEL #' normalize_all_rat_arrays_liver.R|awk '{print}; /list.files/{print("print(length(cel_files));")}' > normalize_nrw_rat_arrays_liver.R
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/rat/normalize_nrw_rat_arrays_liver.R >> normalization_run_time_nrw_rat_cel_files.txt

# Like before I manually created and edited the file ratio_info_for_NRW_data_manually_edited.tsv
average_ratio_for_nrw_data:
	mkdir nrw_data/average_ratio
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./nrw_data/raw_data/all_nrw_rat_cel_files_rma_normalized.tsv ./ratio_info_for_NRW_data_manually_edited.tsv ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio.tsv

add_nrw_data_class_info:
	cut -f1 ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio.tsv|grep ENSR > ./nrw_data/average_ratio/gene_names_in_nrw_data.txt;
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio.tsv  ./ratio_info_for_NRW_data_manually_edited.tsv ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_class_info.tsv  ./nrw_data/average_ratio/gene_names_in_nrw_data.txt |tee ./nrw_data/average_ratio/run_nrw_data_normalized_avg_ratio_class_info.log

# This target is identical to average_ratio_for_nrw_data, but the only difference is I removed low dose samples.
average_ratio_for_nrw_data_no_low_dose:
	grep -v '_low_' ./ratio_info_for_NRW_data_manually_edited.tsv > ./ratio_info_for_NRW_data_manually_edited_no_low_dose.tsv
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio_discard_no_meta_info.R --args ./nrw_data/raw_data/all_nrw_rat_cel_files_rma_normalized.tsv ./ratio_info_for_NRW_data_manually_edited_no_low_dose.tsv ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_no_low_dose.tsv

# This target is identical to add_nrw_data_class_info, but the only difference is I removed low dose samples.
add_nrw_data_class_info_no_low_dose:
	cut -f1 ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_no_low_dose.tsv|grep ENSR > ./nrw_data/average_ratio/gene_names_in_nrw_data_no_low_dose.txt;
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_no_low_dose.tsv  ./ratio_info_for_NRW_data_manually_edited_no_low_dose.tsv ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_class_info_no_low_dose.tsv  ./nrw_data/average_ratio/gene_names_in_nrw_data_no_low_dose.txt |tee ./nrw_data/average_ratio/run_nrw_data_normalized_avg_ratio_class_info_no_low_dose.log

nrw_data_separateCV_classif_univar_filter:
	mkdir -pv ./nrw_data/cross_val_classif_univar_filter/;
	echo "Task nrw_data_separateCV_classif_univar_filter STARTED at: $$(date)" > ./nrw_data/cross_val_classif_univar_filter/run_time.txt; 
	cat ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv|sed -re 's/_at\t/\t/g; s/_at$$//' >  ./nrw_data/cross_val_classif_univar_filter/rat_all3projects_norm_avg_ratio_class_info.tsv
	rsync -auvz ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_class_info.tsv  ./nrw_data/cross_val_classif_univar_filter/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV_UnivarFilter_NRW.R --args $$(pwd)/nrw_data/cross_val_classif_univar_filter/ /share/data/openrisknet/dixa_classification/data/raw/rat/nrw_data/cross_val_classif_univar_filter/rat_all3projects_norm_avg_ratio_class_info.tsv $$(pwd)/nrw_data/cross_val_classif_univar_filter/nrw_data_rma_normalized_avg_ratio_class_info.tsv|tee ./nrw_data/cross_val_classif_univar_filter/run.log
	echo "Task nrw_data_separateCV_classif_univar_filter FINISHED at: $$(date)" >> ./nrw_data/cross_val_classif_univar_filter/run_time.txt;

# This task is very similar to nrw_data_separateCV_classif_univar_filter, but no CV and no univariate filtering would be done.
nrw_data_classification:
	mkdir -pv ./nrw_data/classification/;
	echo "Task nrw_data_classification STARTED at: $$(date)" > ./nrw_data/classification/run_time.txt; 
	cat ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv|sed -re 's/_at\t/\t/g; s/_at$$//' >  ./nrw_data/classification/rat_all3projects_norm_avg_ratio_class_info.tsv
	rsync -auvz ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_class_info.tsv  ./nrw_data/classification/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV_noUnivarFilter.R --args $$(pwd)/nrw_data/classification/ /share/data/openrisknet/dixa_classification/data/raw/rat/nrw_data/classification/rat_all3projects_norm_avg_ratio_class_info.tsv $$(pwd)/nrw_data/classification/nrw_data_rma_normalized_avg_ratio_class_info.tsv|tee ./nrw_data/classification/run.log
	echo "Task nrw_data_classification FINISHED at: $$(date)" >> ./nrw_data/classification/run_time.txt;

# This task is very similar to nrw_data_separateCV_classif_univar_filter, but no CV and no univariate filtering would be done.
nrw_data_classif_signif_genes:
	mkdir -pv ./nrw_data/classif_signif_genes/;
	echo "Task nrw_data_classif_signif_genes STARTED at: $$(date)" > ./nrw_data/classif_signif_genes/run_time.txt; 
	cat ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv|sed -re 's/_at\t/\t/g; s/_at$$//' >  ./nrw_data/classif_signif_genes/rat_all3projects_norm_avg_ratio_class_info.tsv
	rsync -auvz ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_class_info.tsv  ./nrw_data/classif_signif_genes/
	sed -re 's/_at\t/\t/g; s/_at$$//' /share/data/openrisknet/dixa_classification/data/raw/rat/iterative_gene_selection/run_4/significant_variables.txt >  ./nrw_data/classif_signif_genes/significant_genes_iter4.txt
	export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/3.5/ && R -q --max-ppsize=50000 --file=/share/data/openrisknet/dixa_classification/data/raw/jb_caret_noCV_noUnivarFilter_selectedGenes.R  --args $$(pwd)/nrw_data/classif_signif_genes/ /share/data/openrisknet/dixa_classification/data/raw/rat/nrw_data/classif_signif_genes/rat_all3projects_norm_avg_ratio_class_info.tsv $$(pwd)/nrw_data/classif_signif_genes/nrw_data_rma_normalized_avg_ratio_class_info.tsv  $$(pwd)/nrw_data/classif_signif_genes/significant_genes_iter4.txt |tee ./nrw_data/classif_signif_genes/run.log
	echo "Task nrw_data_classif_signif_genes FINISHED at: $$(date)" >> ./nrw_data/classif_signif_genes/run_time.txt;


# This task is almost identical to nrw_data_classification, but only difference is that it is used to do classify without low dose samples
nrw_data_classification_no_low_dose:
	mkdir -pv ./nrw_data/classification_no_low_dose/;
	echo "Task nrw_data_classification_no_low_dose STARTED at: $$(date)" > ./nrw_data/classification_no_low_dose/run_time.txt; 
	cat ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv|sed -re 's/_at\t/\t/g; s/_at$$//' >  ./nrw_data/classification_no_low_dose/rat_all3projects_norm_avg_ratio_class_info.tsv
	rsync -auvz ./nrw_data/average_ratio/nrw_data_rma_normalized_avg_ratio_class_info_no_low_dose.tsv  ./nrw_data/classification_no_low_dose/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV_noUnivarFilter.R --args $$(pwd)/nrw_data/classification_no_low_dose/ /share/data/openrisknet/dixa_classification/data/raw/rat/nrw_data/classification_no_low_dose/rat_all3projects_norm_avg_ratio_class_info.tsv $$(pwd)/nrw_data/classification_no_low_dose/nrw_data_rma_normalized_avg_ratio_class_info_no_low_dose.tsv|tee ./nrw_data/classification_no_low_dose/run.log
	echo "Task nrw_data_classification_no_low_dose FINISHED at: $$(date)" >> ./nrw_data/classification_no_low_dose/run_time.txt;

#####
# MAS5 normalization work
#####
# All rat data preparation with MAS5 normalization, except NRW data
mas5_normalize_all_rat_arrays:
	sed -re 's/\srma\(/ mas5\(/g; s/all_rat_cel_files_rma_normalized/all_rat_cel_files_mas5_normalized/; s/table\(exprData\,/table\(log\(exprData\)\,/' normalize_all_rat_arrays_liver.R > mas5_normalize_all_rat_arrays_liver.R
# The following docker image didn't work properly, so I just installed needed packages in R
#	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/rat/mas5_normalize_all_rat_arrays_liver.R >> mas5_normalization_run_time_all_rat_cel_files.txt
# For that reason also change the generated R file to use the correct dir as a working dir. If docker works properly then there is no need for the following two lines
	sed -i.orig -re 's#/raw/rat/all_rat_cel_files_tmp/#/share/data/openrisknet/dixa_classification/data/raw/rat/all_rat_cel_files_tmp/#' mas5_normalize_all_rat_arrays_liver.R
	R --file=./mas5_normalize_all_rat_arrays_liver.R >> mas5_normalization_run_time_all_rat_cel_files.txt

mas5_average_ratio_for_all_3_projects:
	mkdir -pv average_ratio
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args  ./all_rat_cel_files_tmp/all_rat_cel_files_mas5_normalized.tsv  ./ratio_info_for_all_3_projects_manually_edited.tsv ./average_ratio/rat_all_3_projects_mas5_normalized_avg_ratio.tsv

### CHECK this step and maybe also the previous step, then try if everything is OK
mas5_add_class_info:
#	cut -f1 ./average_ratio/rat_all_3_projects_normalized_avg_ratio.tsv|grep ENSR > ./average_ratio/gene_names_in_rat_all_3_projects.txt;
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  ./average_ratio/rat_all_3_projects_mas5_normalized_avg_ratio.tsv ./ratio_info_for_all_3_projects_manually_edited.tsv ./average_ratio/rat_all_3_projects_mas5_normalized_avg_ratio_class_info.tsv  ./average_ratio/gene_names_in_rat_all_3_projects.txt |tee ./average_ratio/run_rat_all_3_projects_mas5_normalized_avg_ratio_class_info.log



# NRW data preparation with MAS5 normalization
mas5_normalize_NRW_rat_arrays:
	sed -re 's#\srma\(# mas5\(#g; s#all_nrw_rat_cel_files_rma_normalized#all_nrw_rat_cel_files_mas5_normalized#; s#table\(exprData\,#table\(log\(exprData\)\,#' normalize_nrw_rat_arrays_liver.R > mas5_normalize_nrw_rat_arrays_liver.R
	time sudo docker run --rm -it -v /share/data/openrisknet/dixa_classification/data/raw/:/raw/ r_base_3.4.0:array R --file=/raw/rat/mas5_normalize_nrw_rat_arrays_liver.R >> ./mas5_normalization_run_time_nrw_rat_cel_files.txt

# Like before I manually created and edited the file ratio_info_for_NRW_data_manually_edited.tsv
mas5_average_ratio_for_nrw_data:
	mkdir -pv nrw_data/average_ratio
	R -q --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/logratio.R --args ./nrw_data/raw_data/all_nrw_rat_cel_files_mas5_normalized.tsv ./ratio_info_for_NRW_data_manually_edited.tsv ./nrw_data/average_ratio/nrw_data_mas5_normalized_avg_ratio.tsv

mas5_add_nrw_data_class_info:
#	cut -f1 ./nrw_data/average_ratio/nrw_data_mas5_normalized_avg_ratio.tsv|grep ENSR > ./nrw_data/average_ratio/gene_names_in_nrw_data.txt;
	R --file=/home/jbayjanov/projects/tgx/dixa_classification/src/data/convert_to_caret_input_format.R --args  ./nrw_data/average_ratio/nrw_data_mas5_normalized_avg_ratio.tsv  ./ratio_info_for_NRW_data_manually_edited.tsv ./nrw_data/average_ratio/nrw_data_mas5_normalized_avg_ratio_class_info.tsv  ./nrw_data/average_ratio/gene_names_in_nrw_data.txt |tee ./nrw_data/average_ratio/run_nrw_data_mas5_normalized_avg_ratio_class_info.log

# This task is very similar to nrw_data_separateCV_classif_univar_filter, but no CV and no univariate filtering would be done. And also done on MAS5-normalised data
mas5_nrw_data_classification:
	mkdir -pv ./nrw_data/mas5_classification/;
	echo "Task mas5_nrw_data_classification STARTED at: $$(date)" > ./nrw_data/mas5_classification/run_time.txt; 
	cat ./average_ratio/rat_all_3_projects_mas5_normalized_avg_ratio_class_info.tsv|sed -re 's/_at\t/\t/g; s/_at$$//' >  ./nrw_data/mas5_classification/rat_all3projects_mas5_norm_avg_ratio_class_info.tsv
	rsync -auvz ./nrw_data/average_ratio/nrw_data_mas5_normalized_avg_ratio_class_info.tsv  ./nrw_data/mas5_classification/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_noCV_noUnivarFilter.R --args $$(pwd)/nrw_data/mas5_classification/ /share/data/openrisknet/dixa_classification/data/raw/rat/nrw_data/mas5_classification/rat_all3projects_mas5_norm_avg_ratio_class_info.tsv $$(pwd)/nrw_data/mas5_classification/nrw_data_mas5_normalized_avg_ratio_class_info.tsv|tee ./nrw_data/mas5_classification/run.log
	echo "Task mas5_nrw_data_classification FINISHED at: $$(date)" >> ./nrw_data/mas5_classification/run_time.txt;

# We noticed that for some compounds we have GTX info, but no CHEMBL id. And this results in the double underscores in the sample names.
# There was only a single compound and we found its corresponding CHEMBL id. The following target corrects that one and also adds some CHEMBL info for ceramide-2,
# but since this compound has no GTX info it will not result in the final array file that will be used in the classification.
# The following target also corrects the sample name in the final array file.
correct_info_and_array_file:
	cp -a ./ratio_info_for_all_3_projects_manually_edited.tsv ./ratio_info_for_all_3_projects_manually_edited.tsv.11jul2019
	sed -i -re 's/butan-1-one\t\t/butan-1-one\tCHEMBL2311069\t/g; s/(butan-1-one.+\t)(study2[1-2])(__)/\1\2_CHEMBL2311069_/g' ./ratio_info_for_all_3_projects_manually_edited.tsv
	sed -i -re 's/(ceramide-2 \(phytosphingosine:N-C24:0\)\t)/\1CHEMBL236036/g' ./ratio_info_for_all_3_projects_manually_edited.tsv
	# I didn't create a copy of the next file, because it can be generated again. However, instead of generating it again I just corrected the sample names.
	sed -i -re 's/(study2[1-2])(__)/\1_CHEMBL2311069_/g' average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv
