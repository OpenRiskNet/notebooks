library(affy)
library('rat2302rnensgcdf')
d1='/raw/rat/all_rat_cel_files_tmp/'
setwd(d1)


print("Normalizing all rat CEL files");
cel_files = list.files(d1,pattern="*.CEL");
#rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="htmg430pmcdf");
rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="rat2302rnensgcdf");
normData <- rma(rawData)
exprData <- exprs(normData)
write.table(exprData, file="all_rat_cel_files_rma_normalized.tsv", sep="\t", col.names=NA, quote=F)

