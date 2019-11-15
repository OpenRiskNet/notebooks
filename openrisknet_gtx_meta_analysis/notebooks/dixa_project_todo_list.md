## TODO List

<!-- This file contains TODO items for this project  -->
* [x] Create a Docker container image for R with the required packages
  I included all necessary R packages in the r_base_3_4_0:array docker image

* [x] Download data from following places:

* [x] DiXa data warehouse: 
  URL: http://wwwdev.ebi.ac.uk/fg/dixa/browsestudies.html

* [x] GEO data

* [x] ArrayExpress

* [x] HepG2 (TGX data)
  - https://academic.oup.com/carcin/article-lookup/doi/10.1093/carcin/bgs182
  - https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE28878

* [x] Check also local files:
Data location: _projects/tgx/dixa_classification/notebooks/_

* [ ] First select best explaining genes in all 3 species and check their similiarity at the functional, pathway level
* [x] An abstract fro EuroTox 31 March 2018

* Orthology based analysis should be done for all species together and also per species separately
* Orthology information can be retrieved using the REST API of the Ensembl
  * Check this: https://rest.ensembl.org/documentation/info/homology_ensemblgene
  * E.g.: curl -X GET "https://rest.ensembl.org/homology/id/ENSG00000157764?target_taxon=10090;content-type=application/json;type=orthologues;format=condensed;sequence=none"
* [x] If possible try this analysis in Julich computers
  * Time in Julich computers when every classification run in parallel is: 29 min
  * Time on our ngs-calc server when all classification models run sequentially: 2h35min (155min)
  * Time with the 10 separate CV sets in parallel on Julich: ~50 minutes
  * Time with the 10 separate CV sets in parallel and also every classification also run in parallel on Julich: was not tested, but would be between 29 and 50 minutes
  * Time with the 10 separate CV sets sequentially one after another on ngs-calc: 873 minutes
* [ ] Biological interpretation of identified genes
  * [ ] Use ConsensusPathDB to analyze top N genes
* [x] Orthologs should be analyzed ASAP
  * [x] Retrieve orthologs of human genes in mouse and rat: 
    * There are in total 9601 common orthologs between these 3 species
  * [x] Using the overlap among these 3 species re-run the classification algorithm
* [ ] Find minimal number of genes that do not decrease the accuracy more than N percent
* [ ] Start writing MM and Results sections
* Add information about "possible outperformance of heterogeneous human cell-models over homogeneous mouse and rat cell models"


### OLD notes
NOTE: From meeting on 11 Jan 2018: 
Only use orthologous genes that are present in all 3 species
Try classification analysis on each species separately
Divide the data into training and test sets

NOTE: From meeting of 31 Jan 2018
* [x] Normalize arrays per platform and per species separately

* [ ] Start classification with human data first and do **NOT** include predictomics data
