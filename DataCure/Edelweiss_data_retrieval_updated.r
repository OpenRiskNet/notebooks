
####PLEASE READ ALL NOTES AND DESCRIPTIONS IN THIS HEADER BEFORE PROCEEDING TO THE CODE
##########################
####Author: Noffisat Oki
####Description: This script provides examples of data cleaning and curation processes for toxicogenomics datasets 
####             using API data retrieval.
####
####Notes: The datasets used in this file are retrieved from the Edelweiss DataExplorer and OpenTox data explorer.
####       They include:
####      1.) Mouse Microarray Data originall collected from the Dixa data wharehouse 
####      2.) Accompanying Metadata information for the microarray data
####      3.) Rat liver pathology data from TG-Gates
####Potential issues: none known

#############################


install.packages('magrittr')
install.packages('jsonlite')
install.packages('httr')
install.packages('data.table')
install.packages('tidyr')
install.packages('RCurl')
install.packages('XML')
install.packages('stringi')
install.packages('tidyverse')
#install.packages('rjson')
library(magrittr)
library(jsonlite)
library(httr)
library(data.table)
library(tidyr)
library(RCurl)
library(XML)
library(stringi)
library(tidyverse)
#library(rjson)

###Getting microarray data
Microarray_disc <- GET("https://registry.edelweiss.douglasconnect.com/datasets/8b58ffa0-57a2-4a12-bd45-a72b5513fe7c")
Microarray_list <- content(Microarray_disc, as= "text", encoding = "UTF-8")
parsed_data <- Microarray_list%>% fromJSON
Microarray_data_URI <- parsed_data$data$sourceDataUri
Microarray_data <- GET(Microarray_data_URI)
Microarray_data_list <- content(Microarray_data, as= "text", encoding = "UTF-8")
Microarray_parsed_data <- readr::read_tsv(Microarray_data_list)#readr::read_csv(Microarray_data_list)
dim(Microarray_parsed_data)


###Getting schema for microarray data
Microarray_schema_disc <- GET("https://registry.edelweiss.douglasconnect.com/datasets/8b58ffa0-57a2-4a12-bd45-a72b5513fe7c/schema")
Microarray_schema_list <- content(Microarray_schema_disc, as= "text", encoding = "UTF-8")
parsed_schema <- Microarray_schema_list%>% fromJSON
Microarray_schema <- parsed_schema
microarray_schema_table <- Microarray_schema$rootColumn$children$name
microarray_filenames <- microarray_schema_table[-1]
#Microarray_schema

###Getting accompanying metadata
metadata_disc <- GET("https://registry.edelweiss.douglasconnect.com/datasets/0e1410c9-5296-4c5a-8800-d3dc749cee3b/data?limit=497") 
metadata_list <- content(metadata_disc, as= "text", encoding = "UTF-8")
parsed_metadata <- metadata_list%>% fromJSON
metadata <- parsed_metadata$data
#metadata$array_file
## View the number of rows and columns
dim(metadata)
### View the colunm headers
colnames(metadata)

###Extracting relevant data from metadata that match microarray data 
metadata_relevant_index <- which(metadata$array_file %in% microarray_filenames)
metadata_relevant <- metadata[c(metadata_relevant_index),]
head(metadata_relevant)


###Extracting the compounds list
Analysis_compounds <- unique(metadata_relevant$Factor_Value_Compound)
Analysis_compounds

###Adding identifiers to the table that can enable gathering of additional metadata from other sources
###Finding the matching CASRN identifier of the compounds using the NIH cactus tool
caslist <- mat.or.vec(length(Analysis_compounds), 2)#, data=0)
caslist[,1]<- as.matrix(Analysis_compounds)
for (row in 1:nrow(caslist)) {
  call2 <- paste('https://cactus.nci.nih.gov/chemical/structure/',caslist[row, 1],'/cas', sep="")
  cas_get <- GET(URLencode(call2))#, reserved = FALSE, repeated = FALSE)
  casrn <- content(cas_get, as= "text", type = "text/html", encoding = "UTF-8")
  parsetest <- htmlParse(casrn, asText = TRUE)
  plain.text <- xpathSApply(parsetest, "//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)][not(ancestor::form)]", xmlValue)#casrn <- parsed_casrn$
  caslist[row,2] <- plain.text#casrn #parsed_casrn <- casrn%>% fromJSON
}
colnames(caslist) <- c("Compound_Name", "Casrn_status")
###splitting rows with multiple casrn for same compound
caslist2 <- separate_rows(as.data.frame(caslist), Casrn_status, sep='\n')
caslist2$Casrn_status <- as.factor(caslist2$Casrn_status)
##Viewing the information extracted
dim(caslist2)
caslist2


caslist2$CASRN <- as.character(caslist2$Casrn_status)
NF_index <- which(caslist2[,3]=='Page not found (404)')
caslist2[NF_index,3] <- 'NA'   
dim(caslist2)
caslist2
Analysis_list <- caslist2

###GETTING MORE METADATA###############

###Checking for matching compounds from TG-Gates
compounds_disc <- GET("http://open-tggates-api.cloud.douglasconnect.com/v2/compounds?limit=none")
compoundslist <- content(compounds_disc, as= "text", encoding = "UTF-8")
parsed_compounds <- compoundslist%>% fromJSON
compounds <- parsed_compounds$compounds
#Viewing the compunds list extracted from TG-Gateshead(parsed_compounds)
dim(compounds)
head(compounds)

###Adding Casrn to TGG compounds to enable more accurate merging with microarray data
caslist_tgg <- mat.or.vec(nrow(compounds), 3)#, data=0)
caslist_tgg[,c(1:2)]<- as.matrix(compounds[,])
for (row in 1:nrow(caslist_tgg)) {
  call2 <- paste('https://cactus.nci.nih.gov/chemical/structure/',caslist_tgg[row, 2],'/cas', sep="")
  cas_get <- GET(URLencode(call2))
  casrn <- content(cas_get, as= "text", type = "text/html", encoding = "UTF-8")
  parsetest <- htmlParse(casrn, asText = TRUE)
  plain.text <- xpathSApply(parsetest, "//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)][not(ancestor::form)]", xmlValue)#casrn <- parsed_casrn$
  caslist_tgg[row,3] <- plain.text
}

#dim(caslist_tgg)
colnames(caslist_tgg) <- c("_id_", "Compound_Name", "Casrn_status")
###splitting rows with multiple casrn for same compound
caslist2_tgg <- separate_rows(as.data.frame(caslist_tgg), Casrn_status, sep='\n')
caslist2_tgg$Casrn_status <- as.factor(caslist2_tgg$Casrn_status)
###Viewing the TG-Gates data with added CASRN identifiers
dim(caslist2_tgg)
head(caslist2_tgg)

caslist2_tgg$CASRN <- as.character(caslist2_tgg$Casrn)
NF_indextgg <- which(caslist2_tgg[,3]=='Page not found (404)')
caslist2_tgg[NF_indextgg,4] <- 'NA'   
dim(caslist2_tgg)
caslist2_tgg     

###Getting all the pathology data available for compounds in TG-Gates
path_disc <- GET("http://open-tggates-api.cloud.douglasconnect.com/v2/pathologies?limit=none")
pathlist <- content(path_disc, as= "text", encoding = "UTF-8")
parsed_path <- pathlist%>% fromJSON
pathologies <- as.data.frame(parsed_path$pathologies) #parsed_compounds$compounds
head(pathologies)

###Adding the CASRN numbers to the pathology data table
TGG_pathologies_mapping <- unique(merge(caslist2_tgg, pathologies, by.x="Compound_Name", by.y="compoundName" ))
#dim(TGG_pathologies_mapping)
#head(TGG_pathologies_mapping)

###Extracting the TG-gates pathology data relevant for the chemicals in the mouse microarray data
Analysis_tggpath <- unique(merge(Analysis_list, TGG_pathologies_mapping, by.x="CASRN", by.y="CASRN"))
#dim(Analysis_tggpath)
#head(Analysis_tggpath)

###removing uninformative columns
coldrop <- c("Casrn_status.x","Casrn_status.y","_id_.x","_id_.y")
Analysis_tggpath <- Analysis_tggpath[ , !(names(Analysis_tggpath) %in% coldrop)]

colnames(Analysis_tggpath) <- c("CASRN","Compound_Name.Dixalist","Compound_Name.TGG","sampleId","timepointHr","tissue",
                                "doseLevel","finding","topography","severity","spontaneous")

##Viewing the pathology data for the chemicals in the Microarray data which could be mapped to TG-Gates
dim(Analysis_tggpath)
head(Analysis_tggpath)

