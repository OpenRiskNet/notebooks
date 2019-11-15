# Custom classification preprocessing script
# Based on classification_run.R v2.04 (23-04-2013)
# M.L.J. Coonen, dpt. Toxicogenomics, Maastricht University

args = commandArgs(trailingOnly=TRUE);
if(length(args)!=7){
  print(args)
  print("Please specify locations of: sourcedir, outputdir, training_file, validation_file, groups_file, training_file_only_signif_genes, validation_file_only_signif_genes with --args option of R");
  print("There must be at least 5 arguments specified. Quitting!");
  quit(save = "no", status = -1, runLast = TRUE);
}

sourcedir = args[1];
outputdir = args[2];
filename.train = args[3];
filename.test = args[4];
filename.groups = args[5];
training_file_only_signif_genes = args[6];
validation_file_only_signif_genes = args[7];

#filename.groups <- "exp_groups_clinchem_MD-ND.txt"	# A tab-delim file containing in first column 'SampleName' and in second column 'TreatmentGroup'
           				
statmethod <- "ttest" 			# Allowed values: "ttest" / "anova" --> Defines type of statistical preprocessing. Omitted if only TEST-set data is loaded (train.or.test-variable)
train.or.test <- 3				# Variable that indicates if the source data contains only training set (1), only test-set (2), or both (3)
class.row.nr <- 2				# Indicate in which row of the datafile the class information is located
	

######################
#### START SCRIPT ####
######################
setwd(sourcedir)

# Reading of files
if(train.or.test == 1 | train.or.test == 3) {
	training.LogRatios.selected <- read.table(filename.train, sep="\t", header=TRUE, row.names=1)
	groups <- read.table(filename.groups, sep="\t", header=TRUE)
}
if(train.or.test == 2 | train.or.test == 3) {
	validation.LogRatios.selected <- read.table(filename.test, sep="\t", header=TRUE, row.names=1)
}

setwd(outputdir)

### Prepare necessary objects
training.targets.compounds <- NULL
training.targets.compounds$SampleName <- colnames(training.LogRatios.selected)
training.targets.compounds$CompoundClass <- as.character(as.matrix(training.LogRatios.selected[(class.row.nr-1),]))
training.LogRatios.selected <- training.LogRatios.selected[-(class.row.nr-1),]	# Remove compoundclass (=text) from datafile
training.LogRatios.selected <- as.matrix(training.LogRatios.selected) # Convert to matrix
mode(training.LogRatios.selected) <- "numeric" # Convert to numeric matrix (character matrix was caused by text strings in compoundclass row)

u.combinations <- unique(groups[,2])
exp.positions <- list()
for(i in 1:length(u.combinations)) {
	exp.positions[[i]] <- grep(paste("^",u.combinations[[i]],"$",sep=""), groups[,2]) 
}
names(exp.positions) <- u.combinations
rm(u.combinations)


# Perform statistics
if(train.or.test == 1 | train.or.test == 3) {
	cat(paste("Performing statistics. Method = ", statmethod, "...", sep=""))
	if(statmethod == "ttest") {

		##############
		### T-TEST ###
		##############

		# Create a new experimental positions list (since order of dataset has changed since LogRatios-function
		exp.positions.LR <- list()
		for(i in 1:length(exp.positions)) {
			samplenames <- training.targets.compounds$SampleName[exp.positions[[i]]]
			temp <- NULL
			for(p in 1:length(samplenames)) {
				temp[p] <- match(samplenames[p], colnames(training.LogRatios.selected))
			}
			print(samplenames)
			print(temp)
			exp.positions.LR[[i]] <- temp				
		}
		names(exp.positions.LR) <- names(exp.positions)
		
		# Reorder the compoundclasses in same way as exp.positions.LR
		compoundclass <- NULL
		for(i in 1:length(exp.positions)) {
			temp <- training.targets.compounds$CompoundClass[exp.positions[[i]]]
			compoundclass <- c(compoundclass, temp)
			rm(temp)
		}
		
			
		.convForTtest <- function(data.object = NULL, metadata = NULL) {
			# read compoundclass for corresponding reporters in data.object. Convert to factor-class (compatible with ~ in t.test function).
			compoundclass <- factor(metadata)
			
			# Convert data-object into ANOVA-compatible object
			ttest.data <- t(data.object) # Transpose. Rows are now experiments, cols are now reporters
			ttest.data <- list(ttest.data, compoundclass) # Combine data and compoundclass in list (compoundclass is used for stratification in ANOVA)
			names(ttest.data) <- c("data", "compoundclass")
			return(ttest.data)
		}

		ttest.data <- .convForTtest(data.object=training.LogRatios.selected, metadata=compoundclass)

		### Leave-1-compound-out ### 
		left.out <- NULL
		l1o.ttest.pval <- matrix(data=NA, nrow=length(exp.positions.LR), ncol=dim(ttest.data$data)[2], dimnames=(list(names(exp.positions.LR), colnames(ttest.data$data))))
		print(exp.positions.LR)
		time1 <- proc.time()
		for(p in 1:length(exp.positions.LR)) {
			cat(paste("\nProcessing T.test ", p, " out of ", length(exp.positions.LR), sep=""))
			cmp.positions <- exp.positions.LR[[p]]
			print(cmp.positions)
			if (length(na.omit(cmp.positions))==0) next;
			left.out$data <- ttest.data$data[-cmp.positions,]
			left.out$compoundclass <- na.omit(ttest.data$compoundclass[-cmp.positions])
			
			# Take out column (= gene)
			for(g in 1:dim(left.out$data)[2]) {
				thisgene <- left.out$data[,g]
				
				# Perform TTEST for this gene
				# print(g)
				# print(length(thisgene))
				# print(length(left.out$compoundclass))
				# print(thisgene)
				# print(left.out$compoundclass)
			
				temp <- t.test(thisgene ~ left.out$compoundclass, var.equal=FALSE) # Tilde ~ stratifies $data
				pval <- temp$p.value
								
				# Store pval for this gene (g) for this left-out compound (p) in overall leave-1-out matrix
				l1o.ttest.pval[p,g] <- pval
				
				# Cleanup
				rm(temp, pval)
				
				# Progress
				if(g %% 1000 == 0) cat(".")
			}
		}

		time2 <- proc.time()
		cat(paste("\nFinished!\nProcessing time:", round(time2[3]-time1[3],3), "s\n"))


		# Store P-value matrix in general matrix
		l1o.pval <- l1o.ttest.pval
		
	}
    
	cat("done\n")


	#######################################
	### SIGNIFICANCY AND REPORTER SELECTION
	#######################################

	cat("Selecting significant reporters...")
	# Transpose the l1o.pval matrix --> Rows = reporters, Columns = Exp conditions
	l1o.pval <- t(l1o.pval)


	# Convert pval-matrix into significancy matrix
	l1o.pval.sig <- ifelse(l1o.pval < 0.01, 1, 0)
	l1o.pval.sig.cnt <- apply(l1o.pval.sig, 1, sum)

	# Store p-values
	write.table(l1o.pval, file="p_values_for_signif_genes.tsv", sep="\t", quote=FALSE);
	write.table(l1o.pval.sig, file="signif_matrix_for_signif_genes.tsv", sep="\t", quote=FALSE);

	# Select only reporters that are significant in all experimental conditions
	reporter.selected <- l1o.pval.sig.cnt == dim(l1o.pval.sig)[2]

	# Select the reporters from the data object
	training.LogRatios.selected.sig.aov <- training.LogRatios.selected[reporter.selected,]
	cat("done\n")
}

if(train.or.test == 1 | train.or.test == 3) {
	# Write selected reporter-names to a file
	cat("Writing list of significant reporters...")
	SelReporterNames <- rownames(training.LogRatios.selected.sig.aov)
	write(SelReporterNames, file=paste("sel_reporters_after_", statmethod, ".txt", sep=""))
	cat(paste("done\nPlease check the output directory for the following file: sel_reporters_after_", statmethod, ".txt\n", sep=""))
}

if(train.or.test == 2) {
	# ## For validation set only
	setwd(sourcedir)
	file.data <- read.table(reporter.file)
	SelReporterNames <- as.character(file.data[,1])
	rm(file.data)
	setwd(outputdir)
}



cat("Writing output files...")
# Add extra row with class-label
if(train.or.test == 1 | train.or.test == 3) {
	if(statmethod == "anova") training.LogRatios.selected.sig.aov <- rbind(as.character(anova.data$compoundclass), training.LogRatios.selected.sig.aov)
	if(statmethod == "ttest") training.LogRatios.selected.sig.aov <- rbind(as.character(ttest.data$compoundclass), training.LogRatios.selected.sig.aov)
}

if(train.or.test == 2 | train.or.test == 3) {
	# Selection of same (significant) reporters from validation set
	validation.LogRatios.selected.sig.aov <- validation.LogRatios.selected[SelReporterNames,]
	validation.LogRatios.selected.sig.aov <- rbind(validation.LogRatios.selected[(class.row.nr-1),], validation.LogRatios.selected.sig.aov)
}

if(train.or.test == 1 | train.or.test == 3) {
	# # Write output files
	write.table(training.LogRatios.selected.sig.aov, training_file_only_signif_genes, sep="\t", col.names=NA)
}
if(train.or.test == 2 | train.or.test == 3) {
	write.table(validation.LogRatios.selected.sig.aov, validation_file_only_signif_genes, sep="\t", col.names=NA)
}
	
cat("done\n")
cat("Please check the output directory for the following files:\n")
if(train.or.test == 1 | train.or.test == 3) {	
	cat(paste(getwd(),"/",training_file_only_signif_genes,sep=""));
}
if(train.or.test == 2 | train.or.test == 3) {	
	cat(paste(getwd(),"/",validation_file_only_signif_genes,sep=""));
}


#### END OF CLASSIFICATION SCRIPT ####


