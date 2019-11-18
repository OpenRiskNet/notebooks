library(affy)
library('rat2302rnensgcdf')
d1='/share/data/openrisknet/dixa_classification/data/raw/rat/all_rat_cel_files_tmp/'
setwd(d1)


print("Normalizing all rat CEL files");
cel_files = list.files(d1,pattern="*.CEL");
#rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="htmg430pmcdf");
rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="rat2302rnensgcdf");
normData <- mas5(rawData)
exprData <- exprs(normData)
write.table(log(exprData), file="all_rat_cel_files_mas5_normalized.tsv", sep="\t", col.names=NA, quote=F)

