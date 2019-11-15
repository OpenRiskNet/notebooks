library(affy)
library('hgu133plus2hsensgcdf')
d1='/raw/human/hg_u133plus2_arrays/'
setwd(d1)


print("Normalizing all human hg_u133plus2_arrays CELfiles");
cel_files = list.files(d1,pattern="*.CEL");
#rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="htmg430pmcdf");
rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="hgu133plus2hsensgcdf");
normData <- rma(rawData)
exprData <- exprs(normData)
write.table(exprData, file="human_hg_u133plus2_arrays_normalized.tsv", sep="\t", col.names=NA, quote=F)

