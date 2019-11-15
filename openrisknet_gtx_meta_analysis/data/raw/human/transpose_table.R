args = commandArgs(trailingOnly=TRUE);
if(length(args)<2){
  print("#Usage:\n\tR --file=transpose_table.R --args input_file tranposed_file");
  q(save="no", status=-1, runLast=TRUE);
}
d1 = read.table(file=args[1],sep="\t",header=TRUE, row.names=1);
d2=t(d1)
write.table(d2, file=args[2], sep="\t", quote=FALSE,col.names=NA)
