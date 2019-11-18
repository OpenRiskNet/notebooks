'''
This module is used to get orthologs of a given gene list in the given species list from Ensemble using Ensemble's REST API.
@autho: J. Bayjan
'''
# Algorithm:
# 0. Retrieve Ensemble's REST version, database version, API version & store the results in the final file name
# 1. Load genes from a genes list file
# 2. For a gene get its orthologue in each species
# 3. Only extract the followings: protein_id, species, id, type
#    So, the final structure would be a tab-delimited file with the following columns:
#    query_gene_id  subject_gene_id subject_protein_id  species orthology_type
# 4. Do steps 2 & 3 for all genes
# 5. Once all genes were retrieved then file to be saved should include Ensemble's REST, DB and API versions
#    ensemble_orthology_REST_XX_DB_XX_API_XX.tsv

# TODO: Maybe get rid of use of the global variables

import requests, sys
from time import sleep

ENSEMBLE_URL = "http://rest.ensembl.org"
ENSEMBLE_INFO_URL = ENSEMBLE_URL + "/info/"
ENSEMBLE_REST = ENSEMBLE_INFO_URL + "rest.json"
ENSEMBLE_DB = ENSEMBLE_INFO_URL +  "data.json"
ENSEMBLE_API = ENSEMBLE_INFO_URL + "software.json"
ensemble_rest_version = ""
ensemble_db_version = ""
ensemble_api_version = ""

genes = []
header = "query_gene_id\tsubject_gene_id\tsubject_protein_id\tspecies\torthology_type"
orthologs = []

def retrieve_ensemble_info():
    global ensemble_rest_version
    global ensemble_db_version
    global ensemble_api_version
    req = requests.get(ENSEMBLE_REST)
    if not req.ok:
        print('Could NOT get Ensemble REST version from: ' + ENSEMBLE_REST + "\nExiting!")
        req.raise_for_status()
        sys.exit()
    ensemble_rest_version = req.json()['release']
    req = requests.get(ENSEMBLE_DB)
    if not req.ok:
        print('Could NOT get Ensemble DB version from: ' + ENSEMBLE_DB + "\nExiting!")
        req.raise_for_status()
        sys.exit()
    ensemble_db_version = str(req.json()['releases'][0])
    req = requests.get(ENSEMBLE_API)
    if not req.ok:
        print('Could NOT get Ensemble API version from: ' + ENSEMBLE_API + "\nExiting!")
        req.raise_for_status()
        sys.exit()
    ensemble_api_version = str(req.json()['release'])
    print("Ensemble info:\nREST: {}\nDB: {}\nAPI: {}".format(ensemble_rest_version, ensemble_db_version, ensemble_api_version))

def load_genes(genes_file, sep="\t"):
    '''Reads a single column genes_file into a genes list'''
    global genes
    tmp = []
    with open(genes_file, "rU") as inp:
        for line in inp:
            arr = line[:-1].split(sep)
            tmp.append(arr[0])
    genes = list(set(tmp))
    print("There are in total {} genes".format(len(genes)))
    del(tmp)
    print("There are in total {} genes".format(len(genes)))

def retrieve_orthology_info(species_names=[]):
    global genes
    global orthologs
    for gene in genes:
        for species in species_names:
            ext = "/homology/id/{}?format=condensed;type=orthologues;target_species={}".format(gene, species)
            req = requests.get(ENSEMBLE_URL+ext, headers={ "Content-Type" : "application/json"})

            if not req.ok:
                req.raise_for_status()
                sys.exit()
            req_data = req.json()['data']
            for rd in req_data:
                for hmlg in rd['homologies']:
                    orthologs.append([gene, hmlg['id'], hmlg['protein_id'], hmlg['species'], hmlg['type']])
        sleep(1)
    print("For {} genes total of {} orthologs retrieved in {} species".format(len(genes), len(orthologs), len(species_names)))

def write_orthology_info(output_file_prefix, sep="\t"):
    global ensemble_rest_version
    global ensemble_db_version
    global ensemble_api_version
    rest_info_suffix = "REST_{}_DB_{}_API_{}.tsv".format(ensemble_rest_version, ensemble_db_version, ensemble_api_version)
    output_file = output_file_prefix + rest_info_suffix
    with open(output_file, 'w') as out:
        out.write(header.strip()+"\n")
        for row in orthologs:
            out.write(sep.join(row) + "\n")
    print("Results are written to the file: " + output_file)

def main(genes_file, output_file_prefix, species_names):
    print("Getting Ensemble API related info")
    retrieve_ensemble_info()
    print("Loading genes")
    load_genes(genes_file=genes_file)
    print("Retrieving orthology info")
    retrieve_orthology_info(species_names=species_names)
    print("Saving results")
    write_orthology_info(output_file_prefix=output_file_prefix)


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("#Usage:\n\t{} genes_file output_file_prefix species_list".format(sys.argv[0]))
        print("species_list is a comma-separated names of species like mouse,rat")
        print("Exiting!")
        sys.exit(1)
    print("Obtained arguments from the command line")
    print(sys.argv)
    genes_file = sys.argv[1]
    output_file_prefix = sys.argv[2]
    species_names = sys.argv[3].split(',')
    main(genes_file=genes_file, output_file_prefix=output_file_prefix, species_names=species_names)
