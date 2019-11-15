# This module is used to convert averaged log-ratio values to caret's format
args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args)!=4){
  print(args)
  print("Please specify locations of: averaged_log_ratios_file, meta_info_file, output_file and common genes file with --args option of R");
  print("There must be at least 4 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}
# array_file = "/mnt/tgx/ngs_data/data/dixa_classification/data/processed/normalized/ketelslegers/liver/ketelslegers_rma_normalized.tsv";
# meta_info_file = "/mnt/tgx/ngs_data/data/dixa_classification/data/processed/training_meta_info/classif_info_for_ketelslegers.tsv";
# output_file="/tmp/ketelslegers.tsv";
print("Supplied parameters are printed in the next line");
print(args);
averaged_log_ratios_file = args[1];
meta_info_file = args[2];
output_file = args[3];
common_genes_file = args[4];

#meta_info_file="/mnt/tgx/ngs_data/data/dixa_classification/data/processed/training_meta_info/classif_info_for_predictomics.tsv"
#array_file="/mnt/tgx/ngs_data/data/dixa_classification/data/processed/averaged_ratios/Predictomics_Study09_HepG2.tsv"
# common_genes_file="/mnt/tgx/ngs_data/data/dixa_classification/data/processed/averaged_ratios/ensg_ids_common_in_all_13_and_2TK6_studies.txt"
# check.names=FALSE was needed because some column names start with the number
averaged_log_ratios=read.table(averaged_log_ratios_file, header = TRUE, sep="\t", row.names = 1, check.names = FALSE)
print(paste("Size of the averaged_log_ratios is (nrow x ncol) :", nrow(averaged_log_ratios), " x ",ncol(averaged_log_ratios)));
meta_info = read.table(file=meta_info_file, header = TRUE, sep='\t', check.names = FALSE)
print(paste("Size of the meta_info is (nrow x ncol) :", nrow(meta_info), " x ",ncol(meta_info)));
common_genes=read.table(common_genes_file, header = FALSE, sep="\t", check.names = FALSE)
print(paste("Size of the common_genes is (nrow x ncol) :", nrow(common_genes), " x ",ncol(common_genes)));
t_normalized = t(averaged_log_ratios[as.character(common_genes[,1]),])
print(paste("Size of the t_normalized is (nrow x ncol) :", nrow(t_normalized), " x ",ncol(t_normalized)));
rownames(t_normalized)=colnames(averaged_log_ratios)
colnames(t_normalized)=as.character(common_genes[,1])
tmp=c()
for(i in 1:nrow(t_normalized)){
  class_info = unique(meta_info[grep(rownames(t_normalized)[i],as.character(meta_info[,17])),5]);
  # If no genotoxicity info is known then discard this entry
  if (isTRUE(gsub(" +","",as.character(class_info))=="") || is.na(class_info)){
    tmp=c(tmp,NA);
  } else{
    tmp=c(tmp,unique(as.character(class_info)));
  }
  if(length(class_info)>1){
    print(paste("Probably there is somwthing is WRONG, possibly an ERROR. There are more than one class for the replicates of the same experiment"));
  }
  print(paste(rownames(t_normalized)[i]," has class: ",class_info," i=",i," length(tmp)=",length(tmp),sep=""));
}
print(paste("Length of the tmp vector is :", length(tmp)));
t1_norm=na.omit(cbind(tmp,t_normalized))
print(paste("Size of the t1_norm is (nrow x ncol) :", nrow(t1_norm), " x ",ncol(t1_norm)));
colnames(t1_norm)[1] = "Class"
cnames = gsub("_at$","",colnames(t1_norm));
colnames(t1_norm) = cnames;
write.table(t1_norm, sep="\t", col.names = NA, file = output_file, quote = FALSE)
