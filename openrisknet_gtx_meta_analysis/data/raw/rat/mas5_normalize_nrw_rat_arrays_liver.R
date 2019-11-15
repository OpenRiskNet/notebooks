library(affy)
library('rat2302rnensgcdf')
#d1='/raw/rat/nrw_data/raw_data/'
d1="/share/data/openrisknet/dixa_classification/data/raw/rat/nrw_data/raw_data/"
setwd(d1)


print("Normalizing all NRW (except T0 ) rat CEL files");
cel_files = list.files(d1,pattern="*.CEL");
print(length(cel_files));
#rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="htmg430pmcdf");
rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="rat2302rnensgcdf");
normData <- mas5(rawData)
exprData <- exprs(normData)
write.table(log(exprData), file="all_nrw_rat_cel_files_mas5_normalized.tsv", sep="\t", col.names=NA, quote=F)

