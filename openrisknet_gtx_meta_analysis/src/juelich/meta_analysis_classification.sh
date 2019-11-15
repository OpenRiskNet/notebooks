#!/bin/bash
#SBATCH -J single_mode_48procs
#SBATCH -N 1
#SBATCH --ntasks-per-node=48
#SBATCH -o single_model_48procs_%j.out
#SBATCH -e single_model_48procs_%j.err
#SBATCH --time=00:10:00
# First activate the bnfinder environment
RUN_ID=$1
echo "Executing run: ${RUN_ID}";
source activate R_3.4.2
cd ~/projects/dixa_classification/data/rat/single_classification

export RUN_ID=$1;
time RUN_ID=$1 make cloud_run_classification ${RUN_ID}

source deactivate
