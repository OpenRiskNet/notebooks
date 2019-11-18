openrisknet_sysgroup
==============================

OpenRiskNet deliverable SYSGROUP for grouping of chemicals based on chemoinformatics data (i.e. Tanimoto scores and protein targets) and transcriptomics

Project Organization
------------

    ├── LICENSE
    ├── Makefile           <- Makefile with commands like `make data` or `make train`
    ├── README.md          <- The top-level README for developers using this project.
    ├── data
    │   ├── external       <- Data from third party sources.
    │   ├── interim        <- Intermediate data that has been transformed.
    │   ├── processed      <- The final, canonical data sets for modeling.
    │   └── raw            <- The original, immutable data dump.
    │
    ├── docs               <- A default Sphinx project; see sphinx-doc.org for details
    │
    ├── models             <- Trained and serialized models, model predictions, or model summaries
    │
    ├── notebooks          <- Jupyter notebooks. Naming convention is a number (for ordering),
    │                         the creator's initials, and a short `-` delimited description, e.g.
    │                         `1.0-jqp-initial-data-exploration`.
    │
    ├── references         <- Data dictionaries, manuals, and all other explanatory materials.
    │
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
    │                         generated with `pip freeze > requirements.txt`
    │
    ├── src                <- Source code for use in this project.
    │   ├── __init__.py    <- Makes src a Python module
    │   │
    │   ├── data           <- Scripts to download or generate data
    │   │   └── make_dataset.py
    │   │
    │   ├── features       <- Scripts to turn raw data into features for modeling
    │   │   └── build_features.py
    │   │
    │   ├── models         <- Scripts to train models and then use trained models to make
    │   │   │                 predictions
    │   │   ├── predict_model.py
    │   │   └── train_model.py
    │   │
    │   └── visualization  <- Scripts to create exploratory and results oriented visualizations
    │       └── visualize.py
    │
    └── tox.ini            <- tox file with settings for running tox; see tox.testrun.org

`git remote add origin https://gitlab.com/bayjan/openrisknet_sysgroup.git`  
`git push -u origin --all`  
`git push -u origin --tags`  

# Steps to integrate 3 different data sets:
1. Prepare transcriptomics data
   1. TG-GATES data was already normalized and only highest dose with 24 hour treatment are obtained using the following command:
   
   ```
   make copy_tg_gates_24h_high_dose_data
   ```
   2. Calculate Euclidean and scaled Euclidean distances among compounds using the transcriptomics data using the following command:
   ```
   make tg_gates_eucl_dist_scaled
   ```
   Note: This is run from a machine, where R packahes ***pamr*** and ***data.table*** were already installed.

   3. Correct scaled Euclidean distance info file by only keeping CHEMBL id. Use the following command:
   ```bash
   make tg_gates_correct_dist_file

2. Get InChiKey using REST URL as following: curl https://www.ebi.ac.uk/chembl/api/data/molecule/CHEMBL101?format=json > chembl101.txt
   1. Or even better use the following Python package: https://github.com/chembl/chembl_webresource_client
   2. Get InChIKey using the following command: inchi_key=`jq . chembl01.json |grep standard_inchi_key|cut -f2 -d':'|sed -re 's/^\s*"//g; s/"//g'`
   
3. Search for CID using InChIKey using the following URL: 
   curl https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/inchikey/${inchi_key}/cids/TXT > cid.txt

    **All steps until now are summarized in the following script**: src/data/get_cids.sh, which I put in the *Makefile* and run as following:
    ```
    make get_inchikey_cid
    ```
   
4. Once all corresponding CIDs are obtained then create a file with all CIDs using the command:
   
   ```
   make only_cids
   ```
   The above command creates a file `./data/processed/only_cids.tsv`, which is used in the next step.
   
5. Upload the same file at the following URL: https://pubchem.ncbi.nlm.nih.gov/score_matrix/score_matrix.cgi
   1. This will calculate a Tanimoto score for each compound.
   2. However, for 4 compounds no score was calculated, probably because it doesn't have sufficient information on these compounds.
   3. Move the downloaded file from `Download` folder to the `data/processed` folder:
   ```
   make modify_tanimoto_scores
   ```
   The above command will copy a csv file and will also create a tsv file with the name `./data/processed/tanimoto_scores.tsv`
   
   4. Tanimoto scores are given in percentage, which needs to be unit-normalized or scaled to [0,1]. That is accomplished using the following command:
   ```
   make percentage_to_unit_scale
   ```
   This step creates a file `data/processed/tanimoto_scores_unit_scaled.tsv`

   5. Map PubChem CIDs to CHEMBL ids using the following command:
   
   ```bash
   make cid2chembl
   ```
   
   6. Convert Tanimoto scores to a distance, by subtracting Tanimoto score from 1.
    Use the following command:
    ```bash
    make tanimoto_score2dist
    ```
   
6. Predict protein targets for each compound:
   1. Pidgin tool would be used to predict protein targets  
   
   First install Pidgin version 3 as described here https://pidginv3.readthedocs.io/en/latest/install.html
   
   ```bash
   make install_pidgin3
   ```
   Get SMILES codes for given CHEMBL ids using the following command:
   ```bash
   make smiles
   ```
   Convert these SMILES codes file to a smi (csv) format using the following command:
   ```bash
   make smiles_smi
   ```
   And then predict protein targets using Pidgin as following:
   
   ```bash
   make compound2protein_pidgin
   ```

   Here we used --ad value of 80, which is 90 by default. However, when we use the default threshold then there is no protein for which we get a score for all compounds.  
   I had also used --ad 60 in addition to --ad 80. But I have now changed it to --ad 0, which will give now to almost all proteins a score so there would be no missing value. You can change that back to value above 50, if results are too noisy.

   Once protein targets were predicted, only select those proteins that had a no-nan activity score. Here nan activity score indicates a missing value. so we are selecting only those proteins that have no missing value. Use the following command to retrieve those proteins:
   ```bash
   make pidgin_non_missing_targets  
   ```
   
   1. Maybe we can also use the cheml_webresource_client Python package to query pre-predicted protein targets for each compound
   
   ```bash
   conda create -n chembl chembl_webresource_client==0.10.0|tee ~/install/sysgroup_chembl_env.txt
   conda activate chembl
   <....>
   conda deactivate
   ```

   **Note:** I have tested both, but it seems `cheml_webresource_client` can't be used for this purpose. So, we are going to use Pidgin version 3.
   
7. Calculate Euclidean distance among compounds using protein targets

   Use the following command:

   ```bash
   make pidgin_eucl_dist_scaled
   ```

8.  Combine the following **three** data sets:  
    A. Euclidean distance matrix of transcriptomics data for each compound   
    B. Structure similarity score calculated using Tanimoto score  
    C. Euclidean distance matrix using protein activity information
    1. First make sure row and column names are in the same order using the following command:
    ```bash
    make order_compounds_correctly
    ```
    1. Use the following command to generate iClusterPlus plot that integrates all 3 data sets.  It is strange, however, that it is not possible to show the name of a data set. At least I couldn't do it. So, panels represent: transcriptome, structure and protein activity based distances between 139 compounds. Resulting image will be transcriptome_structure_protactivity.pdf and going to be located under data/processed. The cluster information will be stored in the same folder in file compound_cluster_info.tsv. Both pdf file and compound_cluster_info.tsv are not put into the git repo.  
   
    ```bash
    make iclusterplus_image
    ```
    Before for test purpose I had used K=3, but I now use K=45 or 46 clusters (~1/3 of 139).
--------
## Note


This project has been set up using PyScaffold 3.2.1. For details and usage
information on PyScaffold see https://pyscaffold.org/.

<p><small>Project based on the <a target="_blank" href="https://drivendata.github.io/cookiecutter-data-science/">cookiecutter data science project template</a>. #cookiecutterdatascience</small></p>
