#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=40G
#SBATCH -c 8

#run_bactofidia
cd ../../../bactofidia
ln -s ../ST131_repo/Ecoli_ncbi_download/results/raw_reads/* .
bash ./bactofidia.sh *.fastq.gz

#move output to folder

#change names back
cd ../ST131_repo/Ecoli_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds
for strain in $(ls *.fna); do 
	new_name=$(echo $strain | sed 's/-/_/g')
	mv $strain $new_name 
done
