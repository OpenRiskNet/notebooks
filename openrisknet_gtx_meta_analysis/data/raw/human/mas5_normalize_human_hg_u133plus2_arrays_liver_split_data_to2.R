library(affy)
library('hgu133plus2hsensgcdf')
d1='/raw/human/hg_u133plus2_arrays/'
setwd(d1)


print("Normalizing all human hg_u133plus2_arrays CELfiles");
cel_files = list.files(d1,pattern="*.CEL");
#rawData <- ReadAffy(filenames=paste(d1,cel_files,sep=""), cdfname="htmg430pmcdf");
print(paste("Total arrays: ",length(cel_files),sep=""))
first_half = as.integer(length(cel_files)/2);
# It requires a large amount of memory so I divide it into two
rawData <- ReadAffy(filenames=paste(d1,cel_files[1:first_half],sep=""), cdfname="hgu133plus2hsensgcdf");
normData <- mas5(rawData)
rm(rawData);
exprData <- exprs(normData)
write.table(exprData, file="./mas5_normalized/human_hg_u133plus2_arrays_mas5_normalized_1st_half.tsv", sep="\t", col.names=NA, quote=F)

# Second half is normalized here
rawData <- ReadAffy(filenames=paste(d1,cel_files[(first_half+1):length(cel_files)],sep=""), cdfname="hgu133plus2hsensgcdf");
normData <- mas5(rawData)
rm(rawData);
exprData <- exprs(normData)
write.table(exprData, file="./mas5_normalized/human_hg_u133plus2_arrays_mas5_normalized_2nd_half.tsv", sep="\t", col.names=NA, quote=F)

