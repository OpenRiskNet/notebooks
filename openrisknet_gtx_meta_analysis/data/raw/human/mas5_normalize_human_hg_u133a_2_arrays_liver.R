library(affy)
library('hgu133a2hsensgcdf')
d1='/raw/human/hg_u133a_2/'
setwd(d1)


print("Normalizing all human hg_u133a_2 CELfiles");
cel_files = list.files(d1,pattern="*.CEL");
#rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="htmg430pmcdf");
print(paste("Total arrays: ",length(cel_files),sep=""))
rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="hgu133a2hsensgcdf");
normData <- mas5(rawData)
exprData <- exprs(normData)
write.table(exprData, file="./mas5_normalized/human_hg_u133a_2_arrays_mas5_normalized.tsv", sep="\t", col.names=NA, quote=F)

