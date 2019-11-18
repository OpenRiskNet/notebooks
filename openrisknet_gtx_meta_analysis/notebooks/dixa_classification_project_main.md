---
title: "DiXa classification project's description"
output:
  pdf_document:
    toc: true
    toc_depth: 2
    highlight: tango
---
# DiXa classification project's description

<!-- I want to put TODO part at the top to know what needs to be done-->
@import "dixa_project_todo_list.md" {output="markdown" class="line-numbers"}

## Data description

@import "../data/liver_data_overview.csv" {output="table"}

## Data preparation

### Prepare names of studies that needs to be downloaded from DiXa

@import "part_01_data_01_01_retrieve_study_names.md" {output="markdown"}
@import "part_01_data_01_02_study_info.md" {output="markdown"}

#### DONE: Copy all of this project to ngs-ada machine and run the retrieval type 2 there

#### TODO: Create a list of compounds studied in the selected work

- Search for s_* files in the downloaded folders and analyze those files for compound names
- Currently ignore this, not a high priority
- Send list of ChemblID:Name to Danyel

#### Normalize all array data

##### DONE Normalize carcinogenomics arrays

- We will only use human arrays
- We will only use liver array data

##### DONE Normalize HepG2 data from Magkoufopoulou et. al (GSE28878) :GSE28878:

- There are only single cell model

##### DONE Normalize Predictomics data

- There are two different cell models: i) Primary hepatocytes; ii) HepG2
- These arrays use the custom cdf format: hgu133a2hsensgcdf

##### DONE Normalize Deferme data
- Data is at: /ngs-data/data_storage/metadata/Deferme/GSE58235_RAW
- Use the file: GSE58235-GPL15798_series_matrix.txt
- These arrays use hthgu133pluspmhsensgcdf cdf package
- Normalize also 3 compounds Lize data separately: ngs-data/data_storage/transcriptomics/microarray/mrna/Deferme/lize_3compounds_archive
- Lize 3 compound data use the same cdf: hthgu133pluspmhsensgcdf

##### DONE Normalize Esnats data

- There is only a single cell model: hSKP-HPC

##### DONE Normalize NTC human liver data

- There is only a single cell model: HepG2

##### DONE Normalize TG-GATES data

- There is only a single cell model: hSKP-HPC

##### DONE Normalize Ketelslegers data

- There is only a single cell model: HepaRG

##### DONE Maybe check all array files with md5sum to see if there are identical files

## DONE Compare common genes between all array data and genes present in TK6 data [5/5]

### DONE Get common genes among all arrays we normalized

### DONE Create a table with all needed information for classification task

### DONE Make meta-data training tables same or similar in their format with one another

### DONE Create train/test data for classification

- Create a log-ratio data and when storing array data use the sample_id as described in the next line
- SampleId should be of the following form: study01_chemblID_concentration_timepoint. (concentration should include millimolar/percent info as well)
- Test caret with carcinogenomics data first.

#### Remove all non-ENSG id rows from normalized array files

#### Create a log-ratio data for training data

#### Create training data in a required format for caret

### DONE Get correct ensemble gene IDs for TK6

## DONE Classify using caret package in R [3/3]

### DONE Classify on training data

### DONE Test the prediction on the test data (TK6 data)

### DONE Use feature elimination and the classify using only best features

## Download data from the following sources

### DiXa data warehouse: 

URL: http://wwwdev.ebi.ac.uk/fg/dixa/browsestudies.html

### GEO data

### ArrayExpress

### TK6 data

These were provided by Danyel:
- https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE58431
- http://www.sciencedirect.com/science/article/pii/S2352340915001699
- https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE51175
- http://onlinelibrary.wiley.com/doi/10.1002/em.21941/epdf
First I downloaded their RAW data and then also their normalized data

### HepG2 (TGX data)

- https://academic.oup.com/carcin/article-lookup/doi/10.1093/carcin/bgs182
- https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE28878

Data location: _projects/tgx/dixa_classification/notebooks/_


## Analysis

### Normalization

Normalization results are stored in the folders **human/** **rat/** and **mouse/** under the folder **/home/jbayjanov/projects/tgx/dixa_classification/data/raw** on **ngs-calc** machine.

## Results

#### Brief information about data

@import "data_overview_report.md" {output="markdown"}

### Classification results for human arrays

**This temporary and the results may change**

#### Human arrays classification results

![human_arrays](../temp/classification_results/temp/human/classification/run1/bwplot.png)

#### Rat arrays classification results

![rat_arrays](../temp/classification_results/temp/rat/classification/run1/bwplot.png)


#### Mouse arrays classification results

![mouse_arrays](../temp/classification_results/temp/mouse/classification/run1/bwplot.png)

#### Prediction accuracy on the validation data
##### Best classifier for human data is Logistic regression
```bash {cmd=true output="markdown"}
awk 'NR==1{print("\t"$0,"\n---|---|---");}; NR>1{print}' ../temp/classification_results/temp/human/classification/run1/svmLinearWeights_validation_performance.txt | grep -v V1|tr '\t' '|'|sed -re 's/^/\|/g; s/$/\|/g'
```

##### Best classifier for rat data is Logistic regression
```bash {cmd=true output="markdown"}
awk 'NR==1{print("\t"$0,"\n---|---|---");}; NR>1{print}' ../temp/classification_results/temp/rat/classification/run1/regLogistic_validation_performance.txt|grep -v V1|tr '\t' '|'|sed -re 's/^/\|/g; s/$/\|/g'
```

##### Best classifier for mouse data is Logistic regression
```bash {cmd=true output="markdown"}
awk 'NR==1{print("\t"$0,"\n---|---|---");}; NR>1{print}' ../temp/classification_results/temp/mouse/classification/run1/regLogistic_validation_performance.txt|grep -v V1|tr '\t' '|'|sed -re 's/^/\|/g; s/$/\|/g'
```

![sensitivity_fig1](../../../presentation/presentation/Sensitivity_and_specificity.png)

![sensitivity_fig2](../../../presentation/presentation/Sensitivity_and_specificity_equation.png)

@import "../temp/classification_results/temp/mouse/classification/reg_logistic_results_analysis.csv" {output="table"}

#### Orthology-based analysis

##### Human data
Comparison of validation performances of algorithms in 3 different cases:
- A. All genes with only human microarray data
- B. Human genes with orthologs in rat and mouse with only human microarray data
- C. Human genes with orthologs in rat and mouse with human, rat and mouse microarray data combined

Results:
I compared top *200* genes between all 3 scenarios for the best classification algorithm, which was svmLinear for all 3 cases:

Genes common among A and B: 89 out of 200 top genes from each analysis
Genes common among A and C: 46 out of 200 top genes from each analysis
Genes common among B and C: 64 out of 200 top genes from each analysis
Genes common among A and B and C: 43 out of 200 top genes from each analysis

@import "../temp/classification_results/comparison_results/human_3_cases_comparison.csv" {output="table"}

## Manuscript


<!-- Information jotted down in meetings are shown below -->
@import "dixa_project_meetings.md" {output="markdown"}