library(affy)
library('hgu133plus2hsensgcdf')
d1='/raw/human/ARRAY_FOLDER/'
setwd(d1)
images_folder="XXX";
mas5_folder="mas5_normalized"

print("Creating mas5 normalized images for all human hg_u133plus2_arrays CEL files");
cel_files = list.files(d1,pattern="*.CEL");
print(paste("Total count of CEL files are: ", length(cel_files),sep=""));
for(i in 1:length(cel_files)){
#  print(paste("Before reading a CEL file: ", d1, cel_files[i],sep=""));
  array_content = ReadAffy(filenames=paste(d1,cel_files[i],sep=""), cdfname="hgu133plus2hsensgcdf");
#  print(paste("After  reading a CEL file: ", d1, cel_files[i],sep=""));
  mas5_normalized_exprs = exprs(mas5(array_content));
  mas5_file = sub(".CEL","_mas5_norm.tsv",cel_files[i],ignore.case=T)
  mas5_file1 = paste(d1,"/",mas5_folder,"/",mas5_file,sep="");
#  print(paste("mas5 file is: ", mas5_file1,sep=""));
  write.table(mas5_normalized_exprs, file=mas5_file1, sep="\t", col.names=NA, quote=F)
  mas5_array_content = log(mas5_normalized_exprs);
  max_mas5 = max(mas5_array_content);
  square_image_size=as.integer(ceiling(sqrt(nrow(mas5_array_content))));
  replace_NA_count = as.integer(square_image_size**2 - as.numeric(nrow(mas5_array_content)));
  image_file = sub(".CEL",".png",cel_files[i],ignore.case=T);
  image_file1 = paste(d1,"/",images_folder,"/",image_file,sep=""); 
#  print(paste("Image file is: ", image_file1,sep=""))
  png(filename= image_file1, bg="transparent");
  image(1:square_image_size,1:square_image_size,matrix(c(mas5_array_content/max_mas5,rep(NA,replace_NA_count)),ncol=square_image_size), xlab="",ylab="",axes=FALSE,col=rainbow(nrow(mas5_array_content)));
  dev.off()
}

