args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args)!=4){
  print(args)
  print("Please specify locations of: work_dir, training_file, test_file and model_id with --args option of R");
  print("There must be at least 4 arguments specified. Here model id is just a number to run the classification models in parallel in cloud. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}

print("Provided args:");
print(args);
work_dir = args[1];
training_file = args[2];
test_file = args[3];
model_id = as.integer(args[4]);

# Allow to work with many variables, default is 5000 and I changed it to 50000
options(expressions=50000);

#setwd("/home/jbayjanov/projects/tgx/dixa_classification/data/caret_run")
setwd(work_dir)


library(caret)
#library(doSNOW)
#cl <- makeCluster(32, type = "SOCK")  ## Use 4 processor
#registerDoSNOW(cl)

## Load required libraries for classification models
library("gbm")
library("kernlab")
library("e1071")
library("LiblineaR")

library(doMC)
registerDoMC(cores = 48)


set.seed(998)
## read input

#training<-read.table("all_caret_train_data.tsv",header = TRUE, sep = "\t", row.names = 1)
training <-read.table(file=training_file, header = TRUE, sep = "\t", row.names = 1)

dim(training)


table(training$Class)

### 10 fold 3 repeats cross-validation

#control <- trainControl(method="repeatedcv", number=10, repeats=3,## Estimate class probabilities
#                        classProbs = TRUE,
#                        ## Evaluate performance using 
#                        ## the following function
#                        summaryFunction = twoClassSummary)

control <- trainControl(method="repeatedcv", number=10, repeats=1, allowParallel = TRUE, 
                        classProbs = TRUE,
                        ## Evaluate performance using 
                        ## the following function
                        summaryFunction = twoClassSummary)


## Training of the different models
model1 = NA;
if(model_id == 1){
  set.seed(7);
  model_logistic <- train(Class~., data=training, method="regLogistic", trControl=control);
  model1 <- model_logistic;
} else if(model_id == 2) {
  # Train the RF model 
  set.seed(7)
  modelRf <- train(Class~., data=training, method="rf", trControl=control);
  model1 <- modelRf;
} else if(model_id == 3) {
  # Train the knn model 
  set.seed(7)
  modelKnn<- train(Class~., data=training, method="knn", trControl=control)
  model1 <- modelKnn;
} else if(model_id == 4){
  set.seed(7)
  modelpls<- train(Class~., data=training, method="pls", trControl=control)
  model1 <- modelpls;
} else if(model_id == 5){
  set.seed(7)
  modelgbm<- train(Class~., data=training, method="gbm", trControl=control)
  model1 <- modelgbm;
} else if(model_id == 6){
  set.seed(7)
  modelxgb<- train(Class~., data=training, method="xgbLinear", trControl=control)
  model1 <- modelxgb;
} else if(model_id == 7){
  set.seed(7)
  modelsvmLinear<- train(Class~., data=training, method="svmLinear", trControl=control)
  model1 <- modelsvmLinear;
} else if(model_id == 8){
  set.seed(7)
  # modelSvm <- train(Class~., data=training, method="svmRadial", trControl=control)
  modelsvmLinear2 <- train(Class~., data=training, method="svmLinear2", trControl=control)
  model1 <- modelsvmLinear2;
} else if(model_id == 9){
  set.seed(7)
  model_svmlinearweights <- train(Class~., data=training, method="svmLinearWeights", trControl=control)
  model1 <- model_svmlinearweights;
}
# The models removed from the previous commented list had problems and didn't work properly
# models_list <- list(RF=modelRf, KNN=modelKnn, pls=modelpls, gbm=modelgbm,
#                  xgb=modelxgb, svmLinear=modelsvmLinear, svmLinear2=modelsvmLinear2, svmL_weights=model_svmlinearweights, logistic=model_logistic);

models_list <- list(classification_model=model1)

# results <- resamples(models_list)
# # summarize the distributions
#summary(results)
# 
# png(file = "bwplot_train.png", bg = "transparent")
## boxplots of results
# bwplot(results)
# dev.off()
#
# 
# png(file = "dotplot_train.png", bg = "transparent")
## dot plots of results
# dotplot(results)
# dev.off()
#

## Give prediction results for all models
#allModels <- list(PAM=modelPam, KNN=modelKnn, SVM=modelSvm,RF=modelRf,svmL=modelsvmLinear,pls=modelpls)

allModels <- models_list; 
#pred <- predict(allModels,type="prob")
pred <- predict(allModels,type="raw")
write.table(pred,"training_set_prediction.txt",sep = "\t", col.names=NA, quote=F)

### Variable importance for all models
for (i in allModels){
  ImpMeasure<-data.frame(varImp(i)$importance)
  write.table(ImpMeasure,paste(i$method,"_variable_importance.txt", sep = ""),sep="\t", col.names=NA, quote=F)
}



## Confusion matrix and parameters choosen for each model

for (i in allModels){
  #testPred <- predict(i, training)
  testPred <- predict(i, training, type="raw")
  cf<- confusionMatrix(testPred, training$Class)
  
  write.table(as.matrix(cf, what = "xtabs"),paste(i$method,"_performance.txt", sep = ""),sep="\t", append = TRUE, quote=F)
  write.table(as.matrix(cf, what = "overall"),paste(i$method,"_performance.txt", sep = ""),sep="\t", append = TRUE, quote=F)
  write.table(as.matrix(cf, what = "classes"),paste(i$method,"_performance.txt", sep = ""),sep="\t", append = TRUE, quote=F)
  
  write(i$method, file = "parameters.txt",append = TRUE, sep = "\t")
  write(rbind(colnames(as.matrix(i$bestTune)),as.matrix(i$bestTune)), file = "parameters.txt",append = TRUE, sep = "\t")
  write("      ", file = "parameters.txt",append = TRUE, sep = "\t")
}


### predict the validationset for each model
#testing<-read.table("TK6_test_transposed.txt",header = TRUE, sep = "\t", row.names = 1)
testing<-read.table(file=test_file, header = TRUE, sep = "\t", row.names = 1)

#pred_val <- predict(allModels,newdata=testing,type="prob")
pred_val <- predict(allModels,newdata=testing,type="raw")

write.table(pred_val,"validation_set_prediction.txt",sep = "\t", col.names=NA, quote=F)

#results_val <- resamples(pred_val)
## summarize the distributions
#summary(results_val)

#png(file = "bwplot_validation.png", bg = "transparent")
## boxplots of results
#bwplot(results_val)
#dev.off()


#png(file = "dotplot_validation.png", bg = "transparent")
## dot plots of results
#dotplot(results_val)
#dev.off()


for (i in allModels){
  #valPred <- predict(i, testing, type="prob");
  valPred <- predict(i, testing, type="raw");
  cf<- confusionMatrix(valPred, testing$Class)
  
  write.table(as.matrix(cf, what = "xtabs"),paste(i$method,"_validation_performance.txt", sep = ""),sep="\t", append = TRUE, quote=F)
  write.table(as.matrix(cf, what = "overall"),paste(i$method,"_validation_performance.txt", sep = ""),sep="\t", append = TRUE, quote=F)
  write.table(as.matrix(cf, what = "classes"),paste(i$method,"_validation_performance.txt", sep = ""),sep="\t", append = TRUE, quote=F)
}
