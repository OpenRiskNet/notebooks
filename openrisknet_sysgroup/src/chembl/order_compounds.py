# -*- coding: utf-8 -*-
'''
This module is used to convert PubChem CIDs to CHEMBL ids
@author: J. Bayjan
'''

import pandas as pd

tanimoto = pd.read_csv("tanimoto_scores_unit_scaled_chembl_ids_dist.tsv", sep="\t", index_col=0)
array_data = pd.read_csv("tg_gates_normalized_average_ratio_24h_euclDistScaled.tsv", sep="\t", index_col=0)
protein_distance = pd.read_csv("pidgin3_tg_gates_predictions_ad0_no_missing_only_comps_euclDistScaled.tsv", sep="\t", index_col=0)

tanimoto_compounds = tanimoto.index.values
array_data_compounds = array_data.index.values
protein_distance_compounds = protein_distance.index.values
compounds_present_in_all3 = [name for name in protein_distance_compounds if name in array_data_compounds and name in tanimoto_compounds]

tanimoto_1_index = [i for i in range(tanimoto.shape[0]) if tanimoto.index.values[i] in compounds_present_in_all3]
tanimoto_1_col_index = [i for i in range(tanimoto.shape[1]) if tanimoto.columns.values[i] in compounds_present_in_all3]
tanimoto_1 = tanimoto.take(indices=tanimoto_1_index,axis="index").take(indices=tanimoto_1_col_index,axis="columns")

array_data_1_index = [i for i in range(array_data.shape[0]) if array_data.index.values[i] in compounds_present_in_all3]
array_data_1_col_index = [i for i in range(array_data.shape[1]) if array_data.columns.values[i] in compounds_present_in_all3]
array_data_1 = array_data.take(indices=array_data_1_index,axis="index").take(indices=array_data_1_col_index,axis="columns")

protein_distance_1_index = [i for i in range(protein_distance.shape[0]) if protein_distance.index.values[i] in compounds_present_in_all3]
protein_distance_1_col_index = [i for i in range(protein_distance.shape[1]) if protein_distance.columns.values[i] in compounds_present_in_all3]
protein_distance_1 = protein_distance.take(indices=protein_distance_1_index,axis="index").take(indices=protein_distance_1_col_index,axis="columns")

protein_distance_2 = protein_distance_1.sort_index(axis="index")
protein_distance_2.sort_index(axis="columns", inplace=True)

tanimoto_1.sort_index(axis="index", inplace=True)
tanimoto_1.sort_index(axis="columns", inplace=True)

array_data_1.sort_index(axis="index",inplace=True)
array_data_1.sort_index(axis="columns",inplace=True)

assert all(array_data_1.index.values==array_data_1.columns.values)==True
assert all(array_data_1.index.values==tanimoto_1.columns.values)==True
assert all(protein_distance_2.index.values==tanimoto_1.columns.values)==True

protein_distance_2.to_csv("pidgin3_tg_gates_predictions_ad0_no_missing_only_comps_euclDistScaled_ordered.tsv",sep="\t")
tanimoto_1.to_csv("tanimoto_scores_unit_scaled_chembl_ids_dist_ordered.tsv",sep="\t")
array_data_1.to_csv("tg_gates_normalized_average_ratio_24h_euclDistScaled_ordered.tsv",sep="\t")
