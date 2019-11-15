# Thus module is identical to logratio.R, the only difference is if there is no meta-data info for a given column then 
# instead of quitting it discards that column.

# This module does followings:
# 1. Gets log-ratio of array values
# 2. Calculates the average among replicates
# 3. Writes the final results to the provided file/directory


# 1. This module finds log-ratio of expression values. For that it assumes that all values are already at the log-scale
#    Then it just subtracts control values from exposure (or non-control) values (So: exposure - control (e.g: DMSO))
# 2. Finds the correct replicates and averages the expression values
# 3. Write the results.

# Steps:
#  1. Load normalized arrays for each project separately
#  2. Load corresponding meta-data info file for each project separately
#  3. From the meta-data table find corresponding treatment as following:
#    3.1. Format of the meta-data file is as following:
#    source_name\tstrain\tcompound\tchEMBL_id\tgenotoxicity\tcarcinogenicity\tcontrol\tsample_match\tdose\t
#    dose_unit\ttime\ttime_unit\treplicate\tcontrol_vehicle\tarray_file\tcontrol_file\tfinal_array_name
#    3.2. Get array names from the normalized_arrays data frame
#    3.3. Check column control if it is FALSE then subtract array listed in the column control_file from this array
#    3.4. Append the subtracted results column as an array column in a newly created data frame (log_ration_arrays)
#         with the name that is listed in the final_array_name of the meta data data frame.
args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args)!=3){
  print(args)
  print("Please specify locations of: array_file, meta_info_file and output_file with --args option of R");
  print("There must be at least 3 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}
# array_file = "/mnt/tgx/ngs_data/data/dixa_classification/data/processed/normalized/ketelslegers/liver/ketelslegers_rma_normalized.tsv";
# meta_info_file = "/mnt/tgx/ngs_data/data/dixa_classification/data/processed/training_meta_info/classif_info_for_ketelslegers.tsv";
# output_file="/tmp/ketelslegers.tsv";
print("Supplied parameters are printed in the next line");
print(args);
array_file = args[1];
meta_info_file = args[2];
output_file = args[3];
# check.names=FALSE was needed because some column names start with the number
meta_info = read.table(file=meta_info_file, header = TRUE, sep='\t', check.names = FALSE)
print(paste("Meta-info file has the shape: ",nrow(meta_info),"x",ncol(meta_info)," (nrowxncol)"));
normalized_arrays=read.table(array_file, header = TRUE, sep="\t", row.names = 1, check.names = FALSE)
print(paste("Normalized arrays file has the shape: ",nrow(normalized_arrays),"x",ncol(normalized_arrays)," (nrowxncol)"));
log_ratios = matrix(0,ncol=0,nrow=0); # Empty matrix for log-ratio results
for(col in colnames(normalized_arrays)){
  print(paste("Processing array: ", as.character(col)));
  loc = which(as.character(meta_info[,15]) %in% as.character(col));
  # Also, check if all of the normalized arrays have meta-info in the meta_info data frame
  if (length(loc)==0){
    print(paste("The following array has no meta-data: ", col, "\nDiscarding this column!",sep=" "));
    next;
  } else if(length(loc)>1){
    print(paste("The following array has more than ONE meta-data: ", col, "\nQuitting!",sep=" "));
    quit(save = "no", status = -1, runLast = TRUE);
  } else if(meta_info[loc[1],7]==FALSE){
    # It means this one is not a control
    control_array = as.character(meta_info[loc[1],16]);
    if (control_array==""){
      print(paste("The control array is not specified for this array: ", col, ". Skipping it!",sep=" "));
      next;
      #quit(save = "no", status = -1, runLast = TRUE);
    }
    # Check if there are multiple control array that are separated by ';'
    if(length(grep(";",control_array))>0){
    	control_arrays = unlist(strsplit(control_array,";"));
    	for(arr in control_arrays){
    	# Check if control array is present in normalized_arrays, if NOT quit
    	    arr_pos = which(colnames(normalized_arrays) %in% as.character(arr));
      	  if(length(arr_pos)==0){
    	     print(paste("The following control array is not present among normalized arrays: ", arr, ". Quitting!",sep=" "));
    	     quit(save = "no", status = -1, runLast = TRUE);
      	  }
    	}
    	# Find avarage of among these control arrays
    	tmp = rowMeans(normalized_arrays[,control_arrays]);
            ratio = normalized_arrays[,as.character(col)] - tmp;
            final_array_name = as.character(meta_info[loc[1],17]);
            if(nrow(log_ratios)==0){
              log_ratios = matrix(ratio);
              colnames(log_ratios)[ncol(log_ratios)] = final_array_name;
            } else {
              log_ratios = cbind(log_ratios,ratio);  
              colnames(log_ratios)[ncol(log_ratios)] = final_array_name;
            }
    } else {
      # Check if control array is present in normalized_arrays, if NOT quit
      if(! control_array %in% colnames(normalized_arrays)){
        print(paste("The following control array is not present among normalized arrays: ", control_array, ". Quitting!",sep=" "));
        quit(save = "no", status = -1, runLast = TRUE);
      }
      ratio = normalized_arrays[,as.character(col)] - normalized_arrays[,control_array]
      final_array_name = as.character(meta_info[loc[1],17]);
      if(nrow(log_ratios)==0){
        log_ratios = matrix(ratio);
        colnames(log_ratios)[ncol(log_ratios)] = final_array_name;
      } else {
        log_ratios = cbind(log_ratios,ratio);  
        colnames(log_ratios)[ncol(log_ratios)] = final_array_name;
      }
    }
  }
}
# Get the average of replicates
# First get unique names by removing _1, _2 or _3 suffices from array names
averaged_arrays=matrix(0,ncol=0, nrow=0); 
ratios_col_names = colnames(log_ratios);
# In some cases there are many more replicates than 9, so there can be more than a single digit
for(uniq_name in unique(gsub("_[1-9]+$","",ratios_col_names))){
  replicate_cols = ratios_col_names[grep(uniq_name,ratios_col_names)];
  if (length(replicate_cols)==0){
    print(paste("No replicate cols in averaging step for name: ",uniq_name,". This should NOT have happened. Exiting!"))
    quit(save = "no", status = -1, runLast = TRUE);
  }
  # If there is no replicate then use the single array as it is
  if (length(replicate_cols)==1){
    tmp = log_ratios[,replicate_cols[1]];
  } else {
    tmp = rowMeans(log_ratios[,replicate_cols]);
  }
  if(nrow(averaged_arrays) == 0){
    averaged_arrays=matrix(tmp);
    colnames(averaged_arrays)[ncol(averaged_arrays)] = uniq_name;
  } else {
    averaged_arrays = cbind(averaged_arrays, tmp);
    colnames(averaged_arrays)[ncol(averaged_arrays)] = uniq_name;
  }
}
if (nrow(averaged_arrays)!= nrow(normalized_arrays)){
  print("Number of rows in avearaged_arrays is not equal to that of normalized_arrays. This should NOT have happened. Quitting!")
  quit(save = "no", status = -1, runLast = TRUE);
}
rownames(averaged_arrays) = rownames(normalized_arrays);
write.table(averaged_arrays, sep="\t", col.names = NA, file = output_file, quote = FALSE)
