#!/bin/bash
curl "https://www.ebi.ac.uk/chembl/api/data/molecule/${1}?format=json" > cid_tmp_chembl_info.json
jq . cid_tmp_chembl_info.json |grep standard_inchi_key|cut -f2 -d':'|sed -re 's/^\s*"//g; s/"//g' > cid_tmp_inchikey.txt
inchi_key=`cat cid_tmp_inchikey.txt`;
curl https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/inchikey/${inchi_key}/cids/TXT > cid_tmp_cid.txt
cid=`cat cid_tmp_cid.txt`
echo -e "${1}\t${inchi_key}\t${cid}"
