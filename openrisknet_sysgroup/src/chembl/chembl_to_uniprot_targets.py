import csv
from chembl_webresource_client.new_client import new_client

# This will be our resulting structure mapping compound ChEMBL IDs into target uniprot IDs
compounds2targets = dict()

# First, let's just parse the csv file to extract compounds ChEMBL IDs:
with open('data/processed/only_chembl_ids_05compounds.tsv', 'r') as csvfile:#'compounds_list.csv', 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        compounds2targets[row[0]] = set()

# OK, we have our source IDs, let's process them in chunks:
chunk_size = 50
keys = list(compounds2targets.keys()) # for Python 3 we need to convert keys() to list

for i in range(0, len(keys), chunk_size):
    # we jump from compounds to targets through activities:
    activities = new_client.activity.filter(molecule_chembl_id__in=keys[i:i + chunk_size]).only(
        ['molecule_chembl_id', 'target_chembl_id'])
    # extracting target ChEMBL IDs from activities:
    for act in activities:
        compounds2targets[act['molecule_chembl_id']].add(act['target_chembl_id'])

# OK, now our dictionary maps from compound ChEMBL IDs into target ChEMBL IDs
# We would like to replace target ChEMBL IDs with uniprot IDs

for key, val in compounds2targets.items():
    # We don't know how many targets are assigned to a given compound so again it's
    # better to process targets in chunks:
    lval = list(val)
    uniprots = set()
    for i in range(0, len(val), chunk_size):
        targets = new_client.target.filter(target_chembl_id__in=lval[i:i + chunk_size]).only(
            ['target_components'])
        uniprots |= set(
            sum([[comp['accession'] for comp in t['target_components']] for t in targets],[]))
    compounds2targets[key] = uniprots

# Finally write it to the output csv file
with open('compounds_2_targets.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    for key, val in compounds2targets.items():
        writer.writerow([key] + list(val))
