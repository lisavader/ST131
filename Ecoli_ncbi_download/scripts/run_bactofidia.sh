#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=40G
#SBATCH -c 8

cd ../..

#clone bactofidia
git clone https://gitlab.com/aschuerch/bactofidia.git bactofidia

#run_bactofidia
cd bactofidia
ln -s ../Ecoli_ncbi_download/results/raw_reads/* .
bash ./bactofidia.sh *.fastq.gz
#move results
mkdir ../Ecoli_ncbi_download/results/shortread_assemblies_bactofidia
mv *results ../Ecoli_ncbi_download/results/shortread_assemblies_bactofidia

#change names back to original
cd ../Ecoli_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds
for strain in $(ls *.fna); do 
	new_name=$(echo $strain | sed 's/-/_/g')
	mv $strain $new_name 
done
