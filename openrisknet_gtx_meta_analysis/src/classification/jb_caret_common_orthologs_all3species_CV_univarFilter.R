####
# This script uses the same classification algorithms, but only uses the orthologous genes that
# are present in all 3 species. And in comparison to the script jb_caret_common_orthologs_withSeparateCV.R this one uses
# data from all 3 species and since the genes are orthologs array data is appended after one another
####

args = commandArgs(trailingOnly = TRUE) # Provide arguments only using --args
if(length(args)!=6){
  print(args)
  print("Please specify locations of: work_dir, human_all_training_and_test_in_single_file, rat_all_training_and_test_in_single_file, 
            mouse_all_training_and_test_in_single_file, orthologs_file and CV_run_count");
  print("Here CV_run_count will start different CV run on a different node, it is an integer between 1 and 10"); 
  print("Call R with --args option of R");
  print("There must be at least 5 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}

print("Provided args:");
print(args);
work_dir = args[1];
human_data_file = args[2];
rat_data_file = args[3];
mouse_data_file = args[4];
orthologs_file = args[5]
cv_run_count = as.integer(args[6]);
number_of_separate_train_test_sets = cv_run_count;

# Some constants
signif_cutoff = 0.05;


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
#all_data1 <-read.table(file=all_data_file, header = TRUE, sep = "\t", row.names = 1)
human_data <-read.table(file=human_data_file, header = TRUE, sep = "\t", row.names = 1)
rat_data <-read.table(file=rat_data_file, header = TRUE, sep = "\t", row.names = 1)
mouse_data <-read.table(file=mouse_data_file, header = TRUE, sep = "\t", row.names = 1)
selected_genes <- read.table(file=orthologs_file,header=TRUE)
cols = gsub("_at","",colnames(human_data));
all_data = human_data[,c(1,which(cols %in% as.character(selected_genes[,1])))]; # Human genes are in the 1st column
cols = gsub("_at","",colnames(rat_data));
rat_data1 = rat_data[,c(1,which(cols %in% as.character(selected_genes[,3])))]; # Human genes are in the 3rd column
colnames(rat_data1) = colnames(all_data);
all_data = rbind(all_data, rat_data1);
cols = gsub("_at","",colnames(mouse_data));
mouse_data1 = mouse_data[,c(1,which(cols %in% as.character(selected_genes[,2])))]; # Human genes are in the 2st column
colnames(mouse_data1) = colnames(all_data);
all_data = rbind(all_data,mouse_data1);
rm(human_data, rat_data, rat_data1, mouse_data, mouse_data1); # Clear some space.
print("Size of all_data BEFORE univariate filtering")
print(dim(all_data))
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
print("Size of all_data AFTER univariate filtering")
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