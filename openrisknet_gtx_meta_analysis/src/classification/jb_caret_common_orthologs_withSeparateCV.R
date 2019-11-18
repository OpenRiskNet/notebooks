####
# This script uses the same classification algorithms, but only uses the orthologous genes that
# are present in all 3 species.
####

args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args)!=4){
  print(args)
  print("Please specify locations of: work_dir, all_training_and_test_in_single_file, orthologs_file and col_number_orth");
  print("Call R with --args option of R");
  print("There must be at least 4 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}

print("Provided args:");
print(args);
work_dir = args[1];
all_data_file = args[2];
orthologs_file = args[3]
col_number_orth = as.integer(args[4])
number_of_separate_train_test_sets = 10;

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
library("fastAdaboost")
library("xgboost")
library("kernlab")
library("e1071")
library("LiblineaR")

library(doMC)
registerDoMC(cores = 24)


set.seed(998)
## read input

#training<-read.table("all_caret_train_data.tsv",header = TRUE, sep = "\t", row.names = 1)
#training <-read.table(file=training_file, header = TRUE, sep = "\t", row.names = 1)
all_data1 <-read.table(file=all_data_file, header = TRUE, sep = "\t", row.names = 1)
selected_genes <- read.table(file=orthologs_file,header=TRUE)
cols = gsub("_at","",colnames(all_data1));
all_data = all_data1[,c(1,which(cols %in% as.character(selected_genes[,col_number_orth])))];
print(dim(all_data))
print(colnames(all_data))
for(r in 1:number_of_separate_train_test_sets){
      set.seed(r*100 + 40);
      training_index = createDataPartition(all_data$Class, p=0.8, list=F, times=1)
      training = all_data[training_index,]
      testing = all_data[-training_index,]
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


      set.seed(7)
      modelsvmLinear<- train(Class~., data=training, method="svmLinear", trControl=control)

      set.seed(7)
      # modelSvm <- train(Class~., data=training, method="svmRadial", trControl=control)
      modelsvmLinear2 <- train(Class~., data=training, method="svmLinear2", trControl=control)

      set.seed(7)
      model_svmlinearweights <- train(Class~., data=training, method="svmLinearWeights", trControl=control)

      # The models removed from the previous commented list had problems and didn't work properly
      models_list <- list(svmLinear=modelsvmLinear, svmLinear2=modelsvmLinear2, svmL_weights=model_svmlinearweights, logistic=model_logistic);


      results <- resamples(models_list)
      # summarize the distributions
      print(summary(results))
      bwplot_file = paste("bwplot_train_run_",r,".png",sep="")
      png(file = bwplot_file, bg = "transparent")
      # boxplots of results
      plot_bw = bwplot(results)
      print(plot_bw)
      dev.off()
      print(paste("bwplot file is: ", bwplot_file,sep=""));

      dotplot_file = paste("dotplot_train_run_",r,".png",sep="");
      png(file = dotplot_file, bg = "transparent")
      # dot plots of results
      plot_dot = dotplot(results)
      print(plot_dot);
      dev.off()
      print(paste("dotplot file is: ", dotplot_file,sep=""));


      ## Give prediction results for all models
      allModels <- models_list; 
      #pred <- predict(allModels,type="prob")
      pred <- predict(allModels,type="raw")
      write.table(pred,paste("training_set_prediction_run_",r,".txt",sep=""),sep = "\t", col.names=NA, quote=F)

      ### Variable importance for all models
      for (i in allModels){
            ImpMeasure<-data.frame(varImp(i)$importance)
      	    write.table(ImpMeasure,paste(i$method,"_variable_importance_run_",r,".txt", sep = ""),sep="\t", col.names=NA, quote=F)
      }


      ## Confusion matrix and parameters choosen for each model
      for (i in allModels){
            #testPred <- predict(i, training)
	    testPred <- predict(i, training, type="raw")
      	    cf<- confusionMatrix(testPred, training$Class)

	    write.table(as.matrix(cf, what = "xtabs"),paste(i$method,"_performance_run_",r,".txt", sep = ""),sep="\t", append = TRUE, quote=F)
	    write.table(as.matrix(cf, what = "overall"),paste(i$method,"_performance_run_",r,".txt", sep = ""),sep="\t", append = TRUE, quote=F)
	    write.table(as.matrix(cf, what = "classes"),paste(i$method,"_performance_run_",r,".txt", sep = ""),sep="\t", append = TRUE, quote=F)
	    params_file = paste("parameters_run_",r,".txt",sep="");
	    write(i$method, file = params_file,append = TRUE, sep = "\t")
	    write(rbind(colnames(as.matrix(i$bestTune)),as.matrix(i$bestTune)), file = params_file,append = TRUE, sep = "\t")
	    write("      ", file = params_file,append = TRUE, sep = "\t")
      }


      ### predict the validationset for each model
      #testing<-read.table(file=test_file, header = TRUE, sep = "\t", row.names = 1)

      #pred_val <- predict(allModels,newdata=testing,type="prob")
      pred_val <- predict(allModels,newdata=testing,type="raw")

      write.table(pred_val,paste("validation_set_prediction_run_",r,".txt",sep=""),sep = "\t", col.names=NA, quote=F)

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


      for (i in allModels){
            #valPred <- predict(i, testing, type="prob");
	    valPred <- predict(i, testing, type="raw");
      	    cf<- confusionMatrix(valPred, testing$Class)
	    val_perf_file = paste(i$method,"_validation_performance_run_",r,".txt", sep = "")
	    write.table(as.matrix(cf, what = "xtabs"), val_perf_file,sep="\t", append = TRUE, quote=F)
	    write.table(as.matrix(cf, what = "overall"),val_perf_file,sep="\t", append = TRUE, quote=F)
	    write.table(as.matrix(cf, what = "classes"),val_perf_file,sep="\t", append = TRUE, quote=F)
      }
}