#Author: Julian Paganini
#Adjusted by Lisa Vader

cd ~/data/mobsuite_test

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

#1. create directory to store slurm jobs
mkdir mob_sbatch_scripts

#2. Create directory to store mob-results
mkdir mob_predictions

#3. Get a list of strain names
accessions=$(cat ~/data/genome_download/longread_ST131_sra_accessions)


#4- create sbatch scripts - this part will create one individual sbatch script for running MOB for the samples
for strain in $accessions
do
echo "#!/bin/bash
#1. Move to the directory that will contain the mob predictions
cd ~/data/mobsuite_test/mob_predictions
#2. Run MOB-suite
mob_recon --infile ~/data/mobsuite_test/assemblies/${strain}/assembly.fasta --outdir ${strain}" > mob_sbatch_scripts/${strain}.sh
done

#5- Run the sbatch scripts
cd mob_sbatch_scripts
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=2:00:00 --mem=5G ${slurm}
done
