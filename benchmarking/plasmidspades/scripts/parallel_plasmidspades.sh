#!/bin/bash

##Author: Julian Paganini
##Modified by: Lisa Vader

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate spades

cd ../results

#make directory for holding the results
mkdir spades_predictions

#get a list of the files
files=$(cat ../../../ST131_ncbi_download/longread_ST131_sra_accessions)

#create folder for temporary slurm scripts
mkdir plasmidspades_slurm_scripts

#create slurm scripts

for strain in $files
do
echo "#!/bin/bash
cd ~/data/ST131_repo/ST131_ncbi_download
plasmidspades.py --only-assembler -1 trimmed_sra_files/${strain}_R1*.fq -2 trimmed_sra_files/${strain}_R2*.fq -o ../benchmarking/plasmidspades/results/spades_predictions/${strain}" > plasmidspades_slurm_scripts/${strain}
done

#Run the scripts
cd plasmidspades_slurm_scripts
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=4:30:00 --mem=20G ${slurm}
done