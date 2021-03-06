args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args)!=3){
  print(args)
  print("Please specify locations of: predictions_results_file, accuracy_report_file and prediction_report_file with --args option of R");
  print("predictions_results_file has 4 columns: array_name, compound, actual, predicted");
  print("accuracy_report_file will be tab-delimitied file as an output of this script and will contain accuracy information")
  print("predictions_report_file has 4 columns: compound, actual, predicted, correct_proportion. This file will alse be generated by this script");
  print("There must be at least 2 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}
predictions_results_file = args[1];
accuracy_report_file = args[2];
predictions_report_file = args[3];

print("Parameters passed are")
print(args)
# R code
df=read.table(file=predictions_results_file,sep="\t",header=T)
comps = as.character(unique(df[,2]))
corectly_predicted = c()
m=matrix(ncol=4,nrow=0)
colnames(m) = c("compound","actual","predicted", "correct_proportion")
for(i in 1:length(comps)){
    ind=which(as.character(df[,2])==as.character(comps[i]));
    correct_count=0;
    for(j in ind){
        if(as.character(df[j,3])==as.character(df[j,4])){
            correct_count = correct_count + 1;
        }
    }
    if(correct_count>1){
        corectly_predicted = c(corectly_predicted,comps[i])
        m = rbind(m,c(comps[i],as.character(df[ind[1],3]),as.character(df[ind[1],3]), paste(correct_count,"/",length(ind),sep="")))
    } else{
        incorrect_label = names(which(table(as.character(df[ind,4]))>1))[1];
        m = rbind(m,c(comps[i],as.character(df[ind[1],3]),incorrect_label, paste(correct_count,"/",length(ind),sep="")))
    }
}
tp=length(which(m[which(m[,2]=="GTX"),3]=="GTX"))
fn=length(which(m[which(m[,3]=="NGTX"),2]=="GTX"))
fp=length(which(m[which(m[,3]=="GTX"),2]=="NGTX"))
tn=length(which(m[which(m[,3]=="NGTX"),2]=="NGTX"))
accuracy = length(corectly_predicted)/length(comps)
sensitivity=tp/(tp+fn)
specifity=tn/(tn+fp)
fnr=1-sensitivity
fpr=1-specifity
accuracy_report = matrix(ncol=5,nrow=1)
colnames(accuracy_report) = c("accuracy", "sensitivity", "fnr", "specifity", "fpr")
accuracy_report[1,] = c(accuracy, sensitivity, fnr, specifity, fpr)
print(paste("The following accuracy report will also be written to the file",accuracy_report_file,sep=""))
print(accuracy_report)
write.table(accuracy_report,file=accuracy_report_file,row.names=F, quote=F, sep="\t")
write.table(m,file=predictions_report_file,row.names=F, quote=F, sep="\t")
