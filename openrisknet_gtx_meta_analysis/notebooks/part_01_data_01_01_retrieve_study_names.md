#### Retrieve study names based on the following criteria

##### Data location info and selection criteria 

- URL: http://wwwdev.ebi.ac.uk/fg/dixa/browsestudies.html
- Ignore the following projects: New-Generis, Envirogenomarkers
- In vitro study. Ignore in-vivo, but include ex-vivo studies
- Array data is available for a given study
- Ignore miRNA and protein arrays, So include only mRNA arrays
- Discard this sample: NTC_WP4.99.1_E01 (from NTC project), for now ignore all NTC projects
- Ignore all "Drug Matrix" projects, except the DIXA-033
- Ignore all "PredTox" projects, as they are all in-vivo experiments
- Retrieve data from this folder: ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/
- TG-GATES data is already available on our servers, but we decided to download from Dixa DB: project id DIXA-006
