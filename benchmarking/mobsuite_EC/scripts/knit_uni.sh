#!/bin/bash
#SBATCH -J mobsuite_EC
#SBATCH --time=20:00:00
#SBATCH --mem=32G
#SBATCH -c 8

#activate conda
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

##run all scripts
#mkdir for storing selected contigsi
echo "Selecting plasmid contigs..."
python select_plasmid_contigs_uni.py
echo "Running mobsuite..."	
bash mobsuite_EC_parallel.sh		
#sleep to wait for mobsuite scripts to finish
sleep 30m
echo "Running quast..."
bash quast_mobsuite_uni.sh
echo "Gathering quast results..."
python gather_quast_results_uni.py
echo "Adding assembly accessions..."
bash add_assembly_accessions.sh
