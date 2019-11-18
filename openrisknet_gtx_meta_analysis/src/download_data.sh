#!/bin/bash
data_dir='/home/jbayjanov/projects/tgx/dixa_classification/data/raw/'
set -o errexit
set -o nounset
set -o pipefail
echo "You should download these arrays to NGS-ada machine, because these files are too big"
cd ${data_dir}
mkdir -pv carcinogenomics
cd carcinogenomics
echo "First downloading array info files"
wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/a_kidney_transcription%20profiling_DNA%20microarray.txt
wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/a_lung_transcription%20profiling_DNA%20microarray.txt
wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/liver/a_liver_transcription%20profiling_DNA%20microarray.txt

echo "Downloading study info files"
wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/s_Kidney.txt
wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/s_Liver.txt
wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/s_Lung.txt

wget --continue -m ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/kidney/micro/
wget --continue -m ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/liver/micro/
wget --continue -m ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/CarcinoGenomics/archive/lung/micro/

echo "From DrugMatrix experiment we only download a single study dixa033"
cd ${data_dir}
mkdir -pv drugmatrix
cd drugmatrix
wget --continue -m ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/DrugMatrix/archive/hepatocyte/

cd ${data_dir}
mkdir -pv esnats
cd esnats
echo "esnats project has 2 studies and we will download them each separately, because they are located at different locations"
mkdir -pv e_mexp_3577
cd e_mexp_3577
wget https://www.ebi.ac.uk/arrayexpress/files/E-MEXP-3577/E-MEXP-3577.processed.1.zip
wget https://www.ebi.ac.uk/arrayexpress/files/E-MEXP-3577/E-MEXP-3577.raw.1.zip
wget https://www.ebi.ac.uk/arrayexpress/files/E-MEXP-3577/E-MEXP-3577.idf.txt
wget https://www.ebi.ac.uk/arrayexpress/files/E-MEXP-3577/E-MEXP-3577.sdrf.txt
echo "WARNING!! Ask from Danyel if we need the files at: https://www.ebi.ac.uk/arrayexpress/files/A-AFFY-44/ as well"
echo "These files are 'Affymetrix GeneChip Human Genome U133 Plus 2.0 [HG-U133_Plus_2]'"
echo "We may need them for normalization!!!"
cd ../
wget --continue -m ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/dixa/Esnats/archive/UKK4_archive

cd ${data_dir}
mkdir -pv tk6
cd tk6
echo "Downloading TK6 data from the following projects"
echo "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE58431"
wget --output-file=GSE58431_RAW.tar "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE58431&format=file"
echo "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE51175"
wget --output-file=GSE51175_RAW.tar "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE51175&format=file"

cd ${data_dir}
mkdir -pv hepg2
cd hepg2
echo "Downloading HepG2 data from https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE28878"
wget --output-file=GSE28878_RAW.tar "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE28878&format=file"
