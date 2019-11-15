
args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args) < 2){
  print(args)
  print("Please specify locations of: input_file, scaled_euclidean_dist_output_file and [transpose] with --args option of R");
  print("Usually, the input_file should replicate-averaged log-ratio values for transcriptomics data")
  print("There must be at least 3 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}

transcriptomics_file=args[1];
#eucl_dist_file = args[2];
#scaled_eucl_dist_file = args[3];
scaled_eucl_dist_file = args[2];
transpose = TRUE;
if(length(args==3)){
  if(toupper(args[3])=="TRUE"){
    transpose = TRUE;
  } else if(toupper(args[3])=="FALSE"){
    transpose = FALSE;
  }
}

library(pamr)
library(data.table)

input <- as.data.frame(read.table(transcriptomics_file, check.names=FALSE,header=T, row.names=1, sep='\t'))
if(transpose){
  ed_input<- as.matrix(dist(t(input), method = "euclidian", upper = TRUE))
} else {
  ed_input<- as.matrix(dist(input, method = "euclidian", upper = TRUE))
}
edsc_input <- ed_input/max(ed_input)
#write.table(ed_input, file=eucl_dist_file, sep='\t', col.names=NA)
write.table(edsc_input, file=scaled_eucl_dist_file, sep='\t', col.names=NA, row.names = TRUE, quote=FALSE);
