#!/bin/bash
#SBATCH -J mobsuite_EC
#SBATCH --time=20:00:00
#SBATCH --mem=32G
#SBATCH -c 8

#activate conda
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

##run all scripts
#mkdir for storing selected contigs
mkdir ../../../ST131_ncbi_download/results/shortread_assemblies_bactofidia/plasmid_scaffolds2
python select_plasmid_contigs.py
bash mobsuite_EC_parallel.sh			
#sleep to wait for mobsuite scripts to finish
sleep 2h
bash quast_mobsuite_bac.sh
python gather_quast_results_mob_bac.py
bash add_assembly_accessions.sh
