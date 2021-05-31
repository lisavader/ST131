#!/bin/bash

##Author: Julian Paganini
##Modified by: Lisa Vader

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate spades

cd ../results

#get a list of the files
files=$(cat longread_ST131_sra_accessions)

#make directory to save the output
mkdir trimmed_sra_files

#create folder for temporary slurm scripts
mkdir trim_slurm_jobs

#create slurm scripts  

for strain in $files
do
echo "#!/bin/bash
cd ../sra_files
trim_galore --quality 20 --dont_gzip --length 20 --paired -j 8 --output_dir ../trimmed_sra_files ${strain}*fastq.gz" > trim_slurm_jobs/${strain}.sh
done

#Run the scripts
cd trim_slurm_jobs
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=1:30:00 --mem=20G ${slurm}
done

