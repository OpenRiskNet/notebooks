.PHONY: clean data lint requirements sync_data_to_s3 sync_data_from_s3

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUCKET = [OPTIONAL] your-bucket-for-syncing-data (do not include 's3://')
PROFILE = default
PROJECT_NAME = openrisknet_sysgroup
PYTHON_INTERPRETER = python
SHELL=/bin/bash

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Install Python Dependencies
requirements: test_environment
	pip install -r requirements.txt

## Make Dataset
data: requirements
	$(PYTHON_INTERPRETER) src/data/make_dataset.py

## Delete all compiled Python files
clean:
	find . -name "*.pyc" -exec rm {} \;

## Lint using flake8
lint:
	flake8 --exclude=lib/,bin/,docs/conf.py .

## Upload Data to S3
sync_data_to_s3:
ifeq (default,$(PROFILE))
	aws s3 sync data/ s3://$(BUCKET)/data/
else
	aws s3 sync data/ s3://$(BUCKET)/data/ --profile $(PROFILE)
endif

## Download Data from S3
sync_data_from_s3:
ifeq (default,$(PROFILE))
	aws s3 sync s3://$(BUCKET)/data/ data/
else
	aws s3 sync s3://$(BUCKET)/data/ data/ --profile $(PROFILE)
endif

## Set up python interpreter environment
create_environment:
ifeq (True,$(HAS_CONDA))
		@echo ">>> Detected conda, creating conda environment."
ifeq (3,$(findstring 3,$(PYTHON_INTERPRETER)))
	conda create --name $(PROJECT_NAME) python=3
else
	conda create --name $(PROJECT_NAME) python=2.7
endif
		@echo ">>> New conda env created. Activate with:\nsource activate $(PROJECT_NAME)"
else
	@pip install -q virtualenv virtualenvwrapper
	@echo ">>> Installing virtualenvwrapper if not already intalled.\nMake sure the following lines are in shell startup file\n\
	export WORKON_HOME=$$HOME/.virtualenvs\nexport PROJECT_HOME=$$HOME/Devel\nsource /usr/local/bin/virtualenvwrapper.sh\n"
	@bash -c "source `which virtualenvwrapper.sh`;mkvirtualenv $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER)"
	@echo ">>> New virtualenv created. Activate with:\nworkon $(PROJECT_NAME)"
endif

## Test python environment is setup correctly
test_environment:
	$(PYTHON_INTERPRETER) test_environment.py

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := show-help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')

#############
# My own targets start from here
#############
## The next step is not generated within  this project, but it is generated  within the META-analysis project located at /share/data/openrisknet/dixa_classification/data/raw/human/ on ngs-calc
#sysgroup_prepare_data:
#	cd average_ratio; \
#	head -1 normalized_join_on_gene_ids_u133plu2_u133pm_T.tsv > tg_gates_normalized_average_ratio_24h.tsv; \
#	for i in $$(cut -f1 normalized_join_on_gene_ids_u133plu2_u133pm_T.tsv|grep 24h|grep study06_|cut -f2 -d_|grep CHEMBL|sort|uniq); do grep "_$${i}_" normalized_join_on_gene_ids_u133plu2_u133pm_T.tsv |grep 24h|grep study06_|sort -Vr|head -1 >> tg_gates_normalized_average_ratio_24h.tsv; done

# Add already normalized and log-ratio calculated file to the processed folder
copy_tg_gates_24h_high_dose_data:
	rsync -auvz /share/data/openrisknet/dixa_classification/data/raw/human/average_ratio/tg_gates_normalized_average_ratio_24h.tsv ./data/processed/
	git add data/processed/tg_gates_normalized_average_ratio_24h.tsv

# This is run from ngs-calc server, where R packahes pamr and data.table were already installed.
# In my case these packages were already installed in my home folder as shown in the export command.
tg_gates_eucl_dist_scaled:
	export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/3.5/; \
	R --file=src/data/calculate_scaled_euclidean_dist.R --args ./data/processed/tg_gates_normalized_average_ratio_24h.tsv data/processed/tg_gates_normalized_average_ratio_24h_euclDistScaled.tsv false

tg_gates_correct_dist_file:
	cd data/processed; \
	rsync -auzv tg_gates_normalized_average_ratio_24h_euclDistScaled.tsv tg_gates_normalized_average_ratio_24h_euclDistScaled.tsv.old; \
	sed -re 's/study06_//g' tg_gates_normalized_average_ratio_24h_euclDistScaled.tsv.old|sed -re 's/(_[^ \t]+)([\t])/\t/g; s/(_[^ \t]+)$)//g; ' > tg_gates_normalized_average_ratio_24h_euclDistScaled.tsv; \
	echo "Check if new file is fine, if NOT interrupted will delete an original file in 1 minute"; \
	sleep 60; \
	rm tg_gates_normalized_average_ratio_24h_euclDistScaled.tsv.old; \
	echo "Deleted the original file tg_gates_normalized_average_ratio_24h_euclDistScaled.tsv.old"

only_compound_chembls:	
	cut -f1 data/processed/tg_gates_normalized_average_ratio_24h.tsv |cut -f2 -d_|sort|uniq > data/processed/only_compound_names.txt

get_inchikey_cid:
	echo -e "chembl_id\tinchi_key\tcid" > data/processed/chembl_inchikey_cid.tsv;
	for i in $$(grep CHEMBL data/processed/only_compound_names.txt ); do echo $${i}; ./src/data/get_cids.sh $${i} >> data/processed/chembl_inchikey_cid.tsv; sleep 3; done|tee run_get_cids.log

# After the step get_inchikey_cid I correct for mistakes and multiple CIDs per CHEMBL id by using only the top 1st hit
# The manually edited file is at: ./data/processed/chembl_inchikey_cid_manually_curated.tsv

only_cids:
	grep CHEMBL ./data/processed/chembl_inchikey_cid_manually_curated.tsv |cut -f3|sort -n > ./data/processed/only_cids.tsv

modify_tanimoto_scores:
#	mv ~/Downloads/31749570605647135.csv ./data/processed/tanimoto_scores.csv
	cat ./data/processed/tanimoto_scores.csv|tr ',' '\t' > ./data/processed/tanimoto_scores.tsv

percentage_to_unit_scale:
	awk 'BEGIN{FS="\t"}; NR==1; NR>1{txt=$$1; for(i=2;i<=NF;i++)txt=txt"\t"$$i/100; print(txt)}' data/processed/tanimoto_scores.tsv > data/processed/tanimoto_scores_unit_scaled.tsv

# Apparently Pidgin tool uses Smiles codes, so I need to re-download this info from CHEMBL.
smiles:
	echo -e "chembl_id\tsmiles" > data/processed/chembl_smiles.tsv;
	for i in $$(grep CHEMBL data/processed/only_compound_names.txt ); do echo $${i}; ./src/data/chembl_smiles.sh $${i} >> data/processed/chembl_smiles.tsv; sleep 3; done|tee run_chembl_smiles.log

# Conversion of smiles from rsv to csv format, which is smi format of Pidgin, needs to be performed before running Pidgin.
smiles_smi:
	grep CHEMBL data/processed/chembl_smiles_manually_curated.tsv|tr '\t' ',' > data/processed/tg_gates_chembl_smiles.smi

install_pidgin3:
	conda create -c rdkit --name pidgin3 python=2.7 pip rdkit scikit-learn=0.19.0 pydot graphviz

# In the following target I had also used --ad 60 and also --ad 80. 
# But I have now changed it to --ad 0, which will give now to almost all proteins a score so there would be no missing value.
compound2protein_pidgin:
	mkdir runs
	conda activate pidgin3; \
	python predict.py -n 20 --ad 0 -f data/processed/tg_gates_chembl_smiles.smi -d ',' --smiles_id_column 0 --smiles_column 1  --organism Homo sapiens -o data/processed/pidgin3_tg_gates_predictions_ad0.txt  > runs/run_pidgin3_tg_gates_predictions_ad0.log; \
	conda deactivate; 


# The file generated by Pidgin would be something like this: pidgin3_tg_gates_predictions_ad80.txt_out_predictions_20191111-145155.txt
# It depends on day and time of the day the command was invoked.
pidgin_non_missing_targets:
	cd data/processed/; \
	awk 'BEGIN{FS="\t"}; NR==1{proteins[$$1]=$$1; print}; NR>1{nans=0;for(i=17;i<=NF; i++)if($$i=="nan")nans+=1; if(nans/NF==0)if(!($$1 in proteins)){print;proteins[$$1]=$$1};}' pidgin3_tg_gates_predictions_ad0.txt_out_predictions_20191114-163230.txt > pidgin3_tg_gates_predictions_ad0_no_miss_no_dupl.tsv; \
	cut -f1,17- pidgin3_tg_gates_predictions_ad0_no_miss_no_dupl.tsv > pidgin3_tg_gates_predictions_ad0_no_missing_only_comps.tsv
#awk 'BEGIN{FS="\t"}; NR==1{proteins[$$1]=$$1; print}; NR>1{nans=0;for(i=17;i<=NF; i++)if($$i=="nan")nans+=1; if(nans/NF==0)if(!($$1 in proteins)){print;proteins[$$1]=$$1};}' pidgin3_tg_gates_predictions_ad80.txt_out_predictions_20191111-145155.txt > pidgin3_tg_gates_predictions_ad80_no_miss_no_dupl.tsv; \
#cut -f1,17- pidgin3_tg_gates_predictions_ad80_no_miss_no_dupl.tsv > pidgin3_tg_gates_predictions_ad80_no_missing_only_comps.tsv

pidgin_eucl_dist_scaled:
	export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/3.5/; \
	R --file=./src/data/calculate_scaled_euclidean_dist.R --args ./data/processed/pidgin3_tg_gates_predictions_ad0_no_missing_only_comps.tsv ./data/processed/pidgin3_tg_gates_predictions_ad0_no_missing_only_comps_euclDistScaled.tsv true
#R --file=./src/data/calculate_scaled_euclidean_dist.R --args ./data/processed/pidgin3_tg_gates_predictions_ad80_no_missing_only_comps.tsv ./data/processed/pidgin3_tg_gates_predictions_ad80_no_missing_only_comps_euclDistScaled.tsv true

cid2chembl:
	cd data/processed/; \
	cut -f1,3 chembl_inchikey_cid_manually_curated.tsv|awk 'NR>1{print("s/"$$2"/"$$1"/g") >> "cid2chembl.sed"}; END{system("sed -f cid2chembl.sed tanimoto_scores_unit_scaled.tsv|sed 's/CID//' > tanimoto_scores_unit_scaled_chembl_ids.tsv")}'; \
	rm cid2chembl.sed

tanimoto_score2dist:
	cd data/processed/; \
	awk 'BEGIN{FS="\t"};NR==1;NR>1{txt=$$1;for(i=2;i<=NF; i++){a=1-$$i; txt=txt"\t"a;} print(txt)}' tanimoto_scores_unit_scaled_chembl_ids.tsv > tanimoto_scores_unit_scaled_chembl_ids_dist.tsv

# Somehow make mixes up source and conda activate/deactivate commands.
order_compounds_correctly:
	bash -c "source activate pyro && cd data/processed && python ../../src/chembl/order_compounds.py && conda deactivate && cd ../.."

iclusterplus_image:
	R --file=src/visualization/iclusterplus_visualizatio.R
