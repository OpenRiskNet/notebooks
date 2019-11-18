"""
This file finds genes that are *mostly* absent in arrays and returns write a new data frame without these genes
Here, mostly absent means that a gene is absent in at least 2 out of 3 replicates per compound and absent in all compounds
"""
import pandas as pd

def filter_absent_genes(pma_table_file, solv_exp_file,  output_file, log2ratio_file, filtered_log2ratio_file):
    #df = pd.read_table(workdir + "/data/interim/PMAtable_217_arrays.tsv",sep="\t")
    df = pd.read_table(pma_table_file,sep="\t")
    #array2compound_info = pd.read_table(workdir + "solvent_to_exposure_with_solvent_column.tsv", sep="\t")
    array2compound_info = pd.read_table(solv_exp_file, sep="\t")
    # Get a unique list of compounds
    compounds=list(set([c for c in array2compound_info['compound'].values]))
    present_genes = []
    for i in range(df.shape[0]):
        absents = [a for a in df.iloc[i,:] if str(a) == "A"]
        cmp_absent_count = 0
        if df.index.values[i].lower().count('affx')>0:
            # These are unnecessary probes, so ignore them
            continue
        if len(absents)/df.shape[1]>0.5:
            #print(df.index.values[i] + " is absent in at least hal of the compounds")
            for cmp in compounds:
                cmp_arrays = array2compound_info.loc[array2compound_info['compound']==cmp,'array_name']
                cmp_solvent_arrays = array2compound_info.loc[array2compound_info['compound']==cmp,'solvent_array_name']
                if len(cmp_arrays)!=3 and len(cmp_solvent_arrays)!=3:
                    print("There is an error in compound arrays count. Compound=" + cmp)
                arr = [a + '.CEL.present' for a in cmp_arrays]
                absence1 = [a for a in df.loc[:,arr].iloc[i] if str(a)=="A"]
                cmp_absent = False
                if len(absence1)>1:
                    cmp_absent = True
                arr = [a + '.CEL.present' for a in cmp_solvent_arrays]
                absence1 = [a for a in df.loc[:,arr].iloc[i] if str(a)=="A"]
                cmp_solvent_absent = False
                if len(absence1)>1:
                    cmp_solvent_absent = True
                if cmp_absent and cmp_solvent_absent:
                    cmp_absent_count += 1
            # If this genes is absent in at least two replicates of a compound and in all compounds then it is absent
        #print(cmp_absent_count)
        if cmp_absent_count != len(compounds):
            present_genes.append(df.index.values[i])
    # Discard absent genes
    no_absent_genes = df.filter(items=present_genes, axis=0)
    no_absent_genes.shape
    column_names = [c.split('.')[0] for c in no_absent_genes.columns]
    no_absent_genes.columns = column_names
    # Change index/row names to get rid of '_at' suffix
    rownames = [r.split('_')[0] for r in no_absent_genes.index.values]
    no_absent_genes.index.values[:] = rownames
    #no_absent_genes.to_csv(workdir + "no_absent_genes.tsv", sep="\t")
    no_absent_genes.to_csv(output_file, sep="\t")
    # Now create a filtered log2ratio file
    log2ratio = pd.read_table(log2ratio_file, sep="\t", index_col=0)
    filtered_log2ratio = log2ratio.filter(items=map(int,rownames), axis=0)
    print(filtered_log2ratio.shape)
    filtered_log2ratio.to_csv(filtered_log2ratio_file,sep="\t")

if __name__ == "__main__":
    import sys
    if len(sys.argv)<6:
        print("#Usage:\n\t%s pma_table_file solvent_expos_comp_info_file output_file log2ratio_file filtered_log2ratio_file" %(sys.argv[0]))
        print("Exiting!")
        sys.exit(1)
    pma_table_file = sys.argv[1]
    solv_exp_file = sys.argv[2]
    output_file = sys.argv[3]
    log2ratio_file = sys.argv[4]
    filtered_log2ratio_file = sys.argv[5]
    filter_absent_genes(pma_table_file, solv_exp_file,  output_file, log2ratio_file, filtered_log2ratio_file)