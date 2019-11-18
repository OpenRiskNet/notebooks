###
# This script is almost identical to jb_caret_withSeparateCV_afterUnivarFilter.R, except it ensures that 
# all samples of a compound can only be in either training data or test data. In script jb_caret_withSeparateCV_afterUnivarFilter.R 
# samples are randomly selected, which leads some samples (e.g.: different dose or duration) of a compound can be in training
# data while other samples of the same componds are in a test data. This results in a highly biased classification accuracy.
# So, in script we used to get very high accuracies due to the misleading random splits of a data in script jb_caret_withSeparateCV_afterUnivarFilter.R


args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args)!=3){
  print(args)
  print("Please specify locations of: work_dir and all_training_and_test_in_single_file and CV_run_count with --args option of R");
  print("Here CV_run_count will start different CV run on a different node, it is an integer between 1 and 10");
  print("There must be at least 2 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}

print("Provided args:");
print(args);
work_dir = args[1];
all_data_file = args[2];
cv_run_count = as.integer(args[3]);

# Some constants
signif_cutoff = 0.05;

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

#training<-read.table("all_caret_train_data.tsv",header = TRUE, sep = "\t", row.names = 1)
#training <-read.table(file=training_file, header = TRUE, sep = "\t", row.names = 1)
all_data <-read.table(file=all_data_file, header = TRUE, sep = "\t", row.names = 1)

####
# Univariate filtering part, consider genes that are significant at the p-value < 0.05
####
signif_cols = c(1) # First column contains responses
for(i in 2:ncol(all_data)){
  a = anovaScores(all_data[,i],all_data[,1]);
  if(a < signif_cutoff){
    signif_cols <- c(signif_cols,i);
  }
}
print(paste("Number of significant genes with p-value < 0.05: ", length(signif_cols)-1, sep=""));
all_data <- all_data[,signif_cols];


# In the next line checking for the presence of CHEMBL is needed, because for some compounds it was difficult to find correct
# CHEMBL id.
sample_names = rownames(all_data)[grep("CHEMBL",rownames(all_data))]
chembl_ids = unlist(lapply(sample_names,function(x){return(paste("_",unlist(strsplit(x,"_"))[2],"_",sep=""));}))
chembl_uniq_ids = unique(chembl_ids)
chembl_gtx_ind=matrix(0,ncol=2,nrow=0)
for(i in 1:length(chembl_uniq_ids)){
chembl_gtx_ind = rbind(chembl_gtx_ind,cbind(chembl_uniq_ids[i],grep(chembl_uniq_ids[i],sample_names)[1]));
}


for(r in 1:cv_run_count){
      print(paste("Started the run: ", r, sep=""));
      set.seed(r*100 + 40);
      training_index1=createDataPartition(all_data[as.integer(chembl_gtx_ind[,2]),c("Class")],p=0.8,list=F,times=1)
      training_indices_with_repeat = c();
      for(i in 1:length(training_index1)){
      training_indices_with_repeat=c(training_indices_with_repeat,grep(chembl_gtx_ind[training_index1[i]],sample_names));
      }
      #training_index = createDataPartition(all_data$Class, p=0.8, list=F, times=1)
      training_index = training_indices_with_repeat;
      training = all_data[training_index,]
      rownames(training) = rownames(all_data)[training_index]
      testing = all_data[-training_index,]
      rownames(testing) = rownames(all_data)[-training_index]
      print("dim(training)")
      print(dim(training))
      print("Class distribution in training data")
      print(table(training$Class))
      
      print("dim(testing)")
      print(dim(testing))
      print("Class distribution in testing data")
      print(table(testing$Class))

      # Just to check which samples were selected, store sample ids and their class info
      df1 = as.data.frame(training[,1])
      rownames(df1) = rownames(training)
      colnames(df1) = colnames(training)[1]
      write.table(df1,file=paste("training_data_run_",r,".tsv",sep=""),sep="\t",row.names=T, quote=F, col.names=NA)

      df2 = as.data.frame(testing[,1])
      rownames(df2) = rownames(testing)
      colnames(df2) = colnames(testing)[1]
      write.table(df2,file=paste("testing_data_run_",r,".tsv",sep=""),sep="\t",row.names=T, quote=F, col.names=NA)
      rm(df1)
      rm(df2)
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

      # Apparently xgbLinear runs fine sometimes with parallel computing, but sometimes it just hangs and stays there with no results keeping the machine busy
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

      #set.seed(7)
      #model_svmLinear3 <- train(Class~., data=training, method="svmLinear3", trControl=control)

      set.seed(7)
      model_svmlinearweights <- train(Class~., data=training, method="svmLinearWeights", trControl=control)
      print("Finished training using SVM Linear Weights");

      #set.seed(7)
      #model_glm <- train(Class~., data=training, method="glm", trControl=control)


      # collect resamples
      # Check if model names are correct in this all models list in the commented list, if you ever use it in the future
      #models_list <- list(PAM=modelPam, RF=modelRf, KNN=modelKnn, pls=modelpls, gbm=modelgbm, adaboost=modeladaboost, 
      #                  xgb=modelxgb, svmL=modelsvmLinear, SVM=modelSvm, svmL3=model_svmLinear3, svmL_weights=model_svmlinearweights,
      #                  glm=model_glm, logistic=model_logistic);

      # The models removed from the previous commented list had problems and didn't work properly
      models_list <- list(PAM=modelPam, RF=modelRf, KNN=modelKnn, pls=modelpls, gbm=modelgbm,
      svmLinear=modelsvmLinear, svmLinear2=modelsvmLinear2, svmL_weights=model_svmlinearweights, logistic=model_logistic, xgb=modelxgb);


      results <- resamples(models_list)
      # summarize the distributions
      print("resamples output")
      print(summary(results))

      bwplot_file = paste("bwplot_train_run_",r,".png",sep="");
      png(file = bwplot_file, bg = "transparent")
      # boxplots of results
      plot_bw = bwplot(results);
      print(plot_bw);
      dev.off()
      print(paste("bwplot file is: ", bwplot_file, sep=""))

      dotplot_file = paste("dotplot_train_run_",r,".png",sep="");
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
      write.table(pred,paste("training_set_prediction_run_",r,".txt",sep=""),sep = "\t",  quote=F, row.names = F);

      print("Started to calculate variable importances");
      ### Variable importance for all models
      for (i in allModels){
            ImpMeasure<-data.frame(varImp(i)$importance)
      	    write.table(ImpMeasure,paste(i$method,"_variable_importance_run_",r,".txt", sep = ""),sep="\t", col.names=NA, quote=F)
      }


      print("Started to predict on training data separately for each classification model")
      ## Confusion matrix and parameters choosen for each model
      for (i in allModels){
        #testPred <- predict(i, training)
        testPred <- predict(i, training, type="raw")
        cf<- confusionMatrix(testPred, training$Class)
        
        write.table(as.matrix(cf, what = "xtabs"),paste(i$method,"_performance_run_",r,".txt", sep = ""),sep="\t", col.names=NA, append = TRUE, quote=F)
        write.table(as.matrix(cf, what = "overall"),paste(i$method,"_performance_run_",r,".txt", sep = ""),sep="\t", col.names=F, append = TRUE, quote=F)
        write.table(as.matrix(cf, what = "classes"),paste(i$method,"_performance_run_",r,".txt", sep = ""),sep="\t", col.names=F, append = TRUE, quote=F)
        params_file = paste("parameters_run_",r,".txt",sep="");
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
      write.table(pred_val,paste("validation_set_prediction_run_",r,".txt",sep=""),sep = "\t", row.names=F, quote=F)

      
      #results_val <- resamples(pred_val)
      ## summarize the distributions
      #summary(results_val)

      #png(file = paste("bwplot_validation_run_",r,".png",sep=""), bg = "transparent")
      ## boxplots of results
      #bwplot(results_val)
      #dev.off()

      #png(file = paste("dotplot_validation_run_",r,".png",sep=""), bg = "transparent")
      ## dot plots of results
      #dotplot(results_val)
      #dev.off()

      print("Started to predict on test data separately for each classification model")

      for (i in allModels){
            #valPred <- predict(i, testing, type="prob");
	    valPred <- predict(i, testing, type="raw");
      	    cf<- confusionMatrix(valPred, testing$Class)
	    val_perf_file = paste(i$method,"_validation_performance_run_",r,".txt", sep = "")
	    write.table(as.matrix(cf, what = "xtabs"), val_perf_file,sep="\t", append = TRUE, quote=F)
	    write.table(as.matrix(cf, what = "overall"),val_perf_file,sep="\t", append = TRUE, quote=F)
	    write.table(as.matrix(cf, what = "classes"),val_perf_file,sep="\t", append = TRUE, quote=F)
      }
      print(paste("Finished the run: ", r, sep=""));

}
