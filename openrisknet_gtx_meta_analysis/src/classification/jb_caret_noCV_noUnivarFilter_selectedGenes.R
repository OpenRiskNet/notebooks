######
# This module is very similar to jb_caret_noCV_UnivarFilter_NRW.R, but only difference is that here no univariate filtering is done.
# And, also there is no cross validation would be done as in jb_caret_noCV_UnivarFilter_NRW.R.
######
args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args)!=4){
  print(args)
  print("Please specify locations of: work_dir, training_file, validation_file and selected_genes_file with --args option of R");
  print("Here CV_run_count will start different CV run on a different node, it is an integer between 1 and 10");
  print("There must be at least 4 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}

print("Provided args:");
print(args);
work_dir = args[1];
training_file = args[2];
validation_data_file = args[3];
selected_genes_file = args[4]

# Allow to work with many variables, default is 5000 and I changed it to 50000
options(expressions=500000);

#setwd("/home/jbayjanov/projects/tgx/dixa_classification/data/caret_run")
setwd(work_dir)


library(caret)
#library(doSNOW)
#cl <- makeCluster(32, type = "SOCK")  ## Use 4 processor
#registerDoSNOW(cl)

## Load required libraries for classification models
library("gbm")
#library("fastAdaboost")
library("xgboost")
library("kernlab")
library("e1071")
library("LiblineaR")
library("pamr")
library("pls")

library(doMC)
registerDoMC(cores = 24)


set.seed(998)
## read input

training_data1 <-read.table(file=training_file, header = TRUE, sep = "\t", row.names = 1)
testing_data1 = read.table(file=validation_data_file, header = TRUE, sep = "\t", row.names = 1)
selected_genes <- read.table(file=selected_genes_file,header=FALSE);

# Only use selected genes
training_data = training_data1[,c(1,which(colnames(training_data1) %in% as.character(selected_genes[,1])))];
testing_data = testing_data1[,c(1,which(colnames(testing_data1) %in% as.character(selected_genes[,1])))];
print("Data frame size with all genes for training data");
print(dim(training_data1))
print("Data frame size with ONLY selected genes for training data");
print(dim(training_data))
print("Data frame size with all genes for testing data");
print(dim(testing_data1))
print("Data frame size with ONLY selected genes for testing data");
print(dim(testing_data))


# Scale the values to unit values scale between 0 and 1.
max_training = max(abs(training_data[,2:ncol(training_data)]));
training_data[,2:ncol(training_data )]= training_data[,2:ncol(training_data)]/max_training;

max_testing = max(abs(testing_data[,2:ncol(testing_data)]));
testing_data[,2:ncol(testing_data)] = testing_data[,2:ncol(testing_data)]/max_testing;

training = training_data;
testing = testing_data;

print("dim(training)")
print(dim(training))
print("Class distribution in training data")
print(table(training$Class))

print("dim(testing)")
print(dim(testing))
print("Class distribution in testing data")
print(table(testing$Class))

### 10 fold 1 repeats cross-validation
control <- trainControl(method="repeatedcv", number=10, repeats=1, allowParallel = TRUE, 
                  classProbs = TRUE, summaryFunction = twoClassSummary)


## Training of the different models
set.seed(7)
model_logistic <- train(Class~., data=training, method="regLogistic", trControl=control)
print("Finished training using logistic regression");

# train the Pam
set.seed(7)
modelPam <- train(Class~., data=training, method="pam", trControl=control)
print("Finished training using PAM");

# Train the RF model 
set.seed(7)
modelRf <- train(Class~., data=training, method="rf", trControl=control)
print("Finished training using Random Forest");

# Train the knn model 
set.seed(7)
modelKnn<- train(Class~., data=training, method="knn", trControl=control)
print("Finished training using kNN");

set.seed(7)
modelpls<- train(Class~., data=training, method="pls", trControl=control)
print("Finished training using PLS");

set.seed(7)
modelgbm<- train(Class~., data=training, method="gbm", trControl=control)
print("Finished training using GBM");

# Apparently xgbLinear runs fine sometimes with parallel computing, but sometimes it just hangs and 
# stays there with no results keeping the machine busy
control_no_parallel <- trainControl(method="repeatedcv", number=10, repeats=1, allowParallel = FALSE, 
                  classProbs = TRUE, summaryFunction = twoClassSummary)

# Also decrease the number of cores to 1 for xgbLinear.
registerDoMC(cores = 1)
print("Started training using xgboost");
set.seed(7)
modelxgb<- train(Class~., data=training, method="xgbLinear", trControl=control_no_parallel)
print("Finished training using xgboost");

registerDoMC(cores = 24)

set.seed(7)
modelsvmLinear<- train(Class~., data=training, method="svmLinear", trControl=control)
print("Finished training using SVM Linear");

set.seed(7)
# modelSvm <- train(Class~., data=training, method="svmRadial", trControl=control)
modelsvmLinear2 <- train(Class~., data=training, method="svmLinear2", trControl=control)
print("Finished training using SVM Linear2");

set.seed(7)
model_svmlinearweights <- train(Class~., data=training, method="svmLinearWeights", trControl=control)
print("Finished training using SVM Linear Weights");

# The models removed from the previous commented list had problems and didn't work properly
models_list <- list(PAM=modelPam, RF=modelRf, KNN=modelKnn, pls=modelpls, gbm=modelgbm,
svmLinear=modelsvmLinear, svmLinear2=modelsvmLinear2, svmL_weights=model_svmlinearweights, logistic=model_logistic, xgb=modelxgb);


results <- resamples(models_list)
# summarize the distributions
print("resamples output")
print(summary(results))
save(results, file="training_results_object.RData");

bwplot_file = "bwplot_train_run.png";
png(file = bwplot_file, bg = "transparent")
# boxplots of results
plot_bw = bwplot(results);
print(plot_bw);
dev.off()
print(paste("bwplot file is: ", bwplot_file, sep=""))

dotplot_file = "dotplot_train_run.png";
png(file = dotplot_file, bg = "transparent")
# dot plots of results
plot_dot = dotplot(results)
print(plot_dot);
dev.off()
print(paste("dotplot file is: ", dotplot_file, sep=""))


## Give prediction results for all models
allModels <- models_list; 
#pred <- predict(allModels,type="prob")
print("Started to predict on training data")
pred <- as.data.frame(predict(allModels,type="raw"));
pred <- cbind(rownames(training), pred);
colnames(pred)[1] = ""
write.table(pred,paste("training_set_prediction_run.txt",sep=""),sep = "\t",  quote=F, row.names = F);

print("Started to calculate variable importances");
### Variable importance for all models
for (i in allModels){
      ImpMeasure<-data.frame(varImp(i)$importance)
      write.table(ImpMeasure,paste(i$method,"_variable_importance_run.txt", sep = ""),sep="\t", col.names=NA, quote=F)
}


print("Started to predict on training data separately for each classification model")
## Confusion matrix and parameters choosen for each model
for (i in allModels){
  #testPred <- predict(i, training)
  testPred <- predict(i, training, type="raw")
  cf<- confusionMatrix(testPred, training$Class)
  
  write.table(as.matrix(cf, what = "xtabs"),paste(i$method,"_performance_run.txt", sep = ""),sep="\t", col.names=NA, append = TRUE, quote=F)
  write.table(as.matrix(cf, what = "overall"),paste(i$method,"_performance_run.txt", sep = ""),sep="\t", col.names=F, append = TRUE, quote=F)
  write.table(as.matrix(cf, what = "classes"),paste(i$method,"_performance_run.txt", sep = ""),sep="\t", col.names=F, append = TRUE, quote=F)
  params_file = "parameters_run.txt";
  write(i$method, file = params_file,append = TRUE, sep = "\t")
  write(rbind(colnames(as.matrix(i$bestTune)),as.matrix(i$bestTune)), file = params_file,append = TRUE, sep = "\t")
  write("      ", file = params_file,append = TRUE, sep = "\t")
}


### predict the validationset for each model
#testing<-read.table(file=test_file, header = TRUE, sep = "\t", row.names = 1)

#pred_val <- predict(allModels,newdata=testing,type="prob")
pred_val <- as.data.frame(predict(allModels,newdata=testing,type="raw"))
pred_val <- cbind(rownames(testing), pred_val)
colnames(pred_val)[1] = ""
write.table(pred_val,file="validation_set_prediction_run.txt",sep = "\t", row.names=F, quote=F)


print("Started to predict on test data separately for each classification model")

# The next line is necessary when we want to observe what went wrong with the pipeline at the prediction stage
saveRDS(allModels, file="allModels_object.rds");
print("Saved allModels into the allModels_object.rds file");

for (i in allModels){
  #valPred <- predict(i, testing, type="prob");
  valPred <- predict(i, testing, type="raw");
  cf<- confusionMatrix(valPred, testing$Class);
  val_perf_file = paste(i$method,"_validation_performance_run.txt", sep = "")
  write.table(as.matrix(cf, what = "xtabs"), val_perf_file,sep="\t", append = TRUE, quote=F)
  write.table(as.matrix(cf, what = "overall"),val_perf_file,sep="\t", append = TRUE, quote=F)
  write.table(as.matrix(cf, what = "classes"),val_perf_file,sep="\t", append = TRUE, quote=F)
}
print("Finished the run");


