#!/bin/bash

##Author: Julian Paganini
##Modified by: Lisa Vader

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate spades

cd ../results

#make directory for holding the results
rm -rf predictions_spades
mkdir predictions_spades

#get a list of the files
files=$(cat ../../../ST131_ncbi_download/results/longread_ST131_sra_accessions)

#create folder for temporary slurm scripts
rm -rf scripts_spades
mkdir scripts_spades

#create slurm scripts

for strain in $files
do
echo "#!/bin/bash
cd ~/data/ST131_repo/ST131_ncbi_download/results
plasmidspades.py --only-assembler -1 trimmed_sra_files/${strain}_R1*.fq -2 trimmed_sra_files/${strain}_R2*.fq -o ../../benchmarking/plasmid_reconstruction/results/spades_predictions/${strain}" > spades_scripts/${strain}
done

#Run the scripts
cd spades_scripts
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=4:30:00 --mem=20G ${slurm}
done
