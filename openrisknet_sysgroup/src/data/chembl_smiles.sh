#!/bin/bash
curl "https://www.ebi.ac.uk/chembl/api/data/molecule/${1}?format=json" > cid_tmp_chembl_info.json;
smiles=`jq '.["molecule_structures"]["canonical_smiles"]' cid_tmp_chembl_info.json|tr -d '"'`;
echo -e "${1}\t${smiles}";
