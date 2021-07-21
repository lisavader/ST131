#!/bin/bash
#SBATCH -J mobsuite_clean
#SBATCH --time=10:00:00
#SBATCH --mem=32G
#SBATCH -c 8

#activate conda
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

##run all scripts
echo 'Removing contamination...'
python remove_contamination_uni.py
echo 'Running quast...'
bash quast_mobsuite_clean.sh
#wait for slurm scripts to finish
sleep 30m
echo 'Gathering quast results...'
python gather_quast_results_mob_uni.py
echo 'Adding assembly accessions...'
bash add_assembly_accessions.sh
