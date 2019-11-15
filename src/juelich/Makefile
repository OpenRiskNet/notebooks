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
	mkdir -pv classification/run_$${RUN_ID};
	echo "Classification STARTED at: $$(date)" > classification/run_$${RUN_ID}_time.txt
	rsync -auz average_ratio/training_data_rat_all_3_projects.tsv ./classification/
	rsync -auz average_ratio/test_data_rat_all_3_projects.tsv  ./classification/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret.R --args $$(pwd)/classification/run_$${RUN_ID}/ /share/data/openrisknet/dixa_classification/data/raw/rat/classification/training_data_rat_all_3_projects.tsv /share/data/openrisknet/dixa_classification/data/raw/rat/classification/test_data_rat_all_3_projects.tsv|tee classification/run_$${RUN_ID}.log
	echo "Classification FINISHED at: $$(date)" >> classification/run_$${RUN_ID}_time.txt

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
	rsync -auz ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv ./cross_val_classification/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_withSeparateCV.R --args $$(pwd)/cross_val_classification/ /share/data/openrisknet/dixa_classification/data/raw/rat/cross_val_classification/rat_all_3_projects_normalized_avg_ratio_class_info.tsv|tee ./cross_val_classification/run.log

selected_genes_separateCV_classif:
	mkdir -pv selected_genes_cross_val_classif/;
	rsync -auz ./average_ratio/rat_all_3_projects_normalized_avg_ratio_class_info.tsv ./selected_genes_cross_val_classif/
	R -q --max-ppsize=50000 --file=/home/jbayjanov/projects/tgx/dixa_classification/src/classification/jb_caret_60genes_withSeparateCV.R --args $$(pwd)/selected_genes_cross_val_classif/ /share/data/openrisknet/dixa_classification/data/raw/rat/cross_val_classification/rat_all_3_projects_normalized_avg_ratio_class_info.tsv $$(pwd)/60_selected_genes.txt|tee ./selected_genes_cross_val_classif/run.log

cloud_split_train_test:
	head -1 rat_all_3_projects_normalized_avg_ratio_class_info.tsv  > training_data_rat_all_3_projects.tsv; \
	head -1 rat_all_3_projects_normalized_avg_ratio_class_info.tsv > test_data_rat_all_3_projects.tsv; \
	awk 'NR>1{a=rand(); if(a<=0.2){print >> "test_data_rat_all_3_projects.tsv";}else{print >> "training_data_rat_all_3_projects.tsv";}}' rat_all_3_projects_normalized_avg_ratio_class_info.tsv


cloud_run_classification:
	mkdir -pv classification/model_$${RUN_ID};
	echo "Classification STARTED at: $$(date)" > classification/model_$${RUN_ID}_time.txt
	rsync -auz training_data_rat_all_3_projects.tsv ./classification/
	rsync -auz test_data_rat_all_3_projects.tsv  ./classification/
	R -q --max-ppsize=50000 --file=jb_caret.R --args $$(pwd)/classification/model_$${RUN_ID}/ `pwd`/classification/training_data_rat_all_3_projects.tsv `pwd`/classification/test_data_rat_all_3_projects.tsv $${RUN_ID}|tee classification/model_$${RUN_ID}_run.log
	echo "Classification FINISHED at: $$(date)" >> classification/model_$${RUN_ID}_time.txt


# Write a visualization part in the R script to create bw and dotplot for validation data
# Currently such plots are generated only for training data-based CV folds

