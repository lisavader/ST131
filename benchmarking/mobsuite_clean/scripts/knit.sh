#!/bin/bash
#SBATCH -J mobsuite_clean
#SBATCH --time=20:00:00
#SBATCH --mem=32G
#SBATCH -c 8

#activate conda
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

##run all scripts
echo 'Removing contamination...'
python remove_contamination.py
echo 'Running quast...'
bash quast_mobsuite_bac_clean.sh
#wait for slurm scripts to finish
sleep 1h
echo 'Gathering quast results...'
python gather_quast_results_mob_bac.py
echo 'Adding assembly accessions...'
bash add_assembly_accessions.sh
