library(iClusterPlus)
library(gplots)
library("lattice")
setwd("~/projects/tgx/openrisknet_sysgroup/data/processed/")
tanimoto = as.matrix(read.table("tanimoto_scores_unit_scaled_chembl_ids_dist_ordered.tsv",row.names=1, header=T));
array_data = as.matrix(read.table("tg_gates_normalized_average_ratio_24h_euclDistScaled_ordered.tsv",row.names=1, header=T));
prot_comps = as.matrix(read.delim("pidgin3_tg_gates_predictions_ad0_no_missing_only_comps_euclDistScaled_ordered.tsv",row.names=1, header=T));
# all.equal(rownames(prot_comps),rownames(tanimoto))
# all.equal(rownames(prot_comps),rownames(array_data))
# all.equal(colnames(prot_comps),colnames(array_data))
# all.equal(colnames(prot_comps),colnames(tanimoto))

# Before for test purpose I had used K=3, but I now use K=45 or 46 clusters (~1/3 of 139).
# I used to use lambda=c(0.1, 0.3, 0.2), but was asked to better change it to lambda=c(0.1, 0.1, 0.1) because each matrix contribute equally.
# I can't judge that properly, so changed it to equal contributions.
non_optim_fit = iClusterPlus(dt1=array_data,dt2=tanimoto, dt3=prot_comps,type=c("gaussian", "gaussian", "gaussian"), lambda=c(0.1, 0.1, 0.1), K=45,maxiter=10)

h=bluered(256)
col.scheme=alist()
col.scheme[[1]]=h
col.scheme[[2]]=h
col.scheme[[3]]=h

pdf(file="transcriptome_structure_protactivity.pdf")
plotHeatmap(fit=non_optim_fit, datasets=list(as.matrix(array_data), as.matrix(tanimoto), as.matrix(prot_comps)), type=c("gaussian", "gaussian", "gaussian"), col.scheme=col.scheme)
dev.off()

# Write the cluster info for each compound
clusters = sort(unique(non_optim_fit$clusters))
comp_cluster=matrix(0,ncol=2,nrow=0)
for(i in 1:length(clusters)){
  comp_cluster = rbind(comp_cluster,cbind(rownames(array_data)[non_optim_fit$clusters==clusters[i]],clusters[i]));
}
colnames(comp_cluster) = c("compound","cluster_id")
write.table(comp_cluster,file="compound_cluster_info.tsv",sep="\t",quote=F,row.names=F)
