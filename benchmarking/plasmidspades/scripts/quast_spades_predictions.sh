#!/bin/bash

#activate conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate quast

#move to root directory
cd ../../..

#make directory for storing quast results
mkdir benchmarking/plasmidspades/results/quast_output

#make directory for storing slurm scripts
mkdir benchmarking/plasmidspades/results/quast_slurm_scripts

#put sra accessions in a variable
sra_accessions=$(cat ST131_ncbi_download/results/longread_ST131_sra_accessions)

for sra_accession in $sra_accessions
do
assembly_accession=$(grep ${sra_accession} ST131_ncbi_download/results/accessions_table.csv | cut -d , -f 1)      #find assembly accession
cd benchmarking/plasmidspades/results/spades_predictions/${sra_accession}
all_bins=$(ls *component* | sed 's/.fasta//g')                                           #get names of all predicted plasmids for this strain
#for each plasmid, perform quast with the corresponding complete assembly as reference
cd ../../../../..
for bin in $all_bins
do
echo "#!/bin/bash
#move to root directory
cd ../../../..
#perform quast
quast -o benchmarking/plasmidspades/results/quast_output/${sra_accession}/${bin} -r ST131_ncbi_download/results/genomes/${assembly_accession}*genomic.fna -m 1000 -t 8 -i 500 --no-snps --ambiguity-usage all benchmarking/plasmidspades/results/spades_predictions/${sra_accession}/${bin}.fasta" > benchmarking/plasmidspades/results/quast_slurm_scripts/${sra_accession}_${bin}
done
done

#Execute slurm scripts
cd benchmarking/plasmidspades/results/quast_slurm_scripts
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=1:00:00 --mem=20G $slurm
done
