#!/bin/bash

#activate conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

cd ~/data

#make directory for storing quast results
mkdir mobsuite_test/quast_output

#put sra accessions in a variable
sra_accessions=$(cat genome_download/longread_ST131_sra_accessions)

for sra_accession in $sra_accessions
do
cd mobsuite_test
assembly_accession=$(grep ${sra_accession} accessions_table.csv | cut -d , -f 1)      #find assembly accession
cd mob_predictions/${sra_accession}
all_bins=$(ls plasmid* | sed 's/.fasta//g')                                           #get names of all predicted plasmids for this strain
cd ~/data
#for each plasmid, perform quast with the corresponding complete assembly as reference
for bin in $all_bins
do
quast -o mobsuite_test/quast_output/${sra_accession}/${bin} -r genome_download/genomes/${assembly_accession}*genomic.fna -m 1000 -t 8 -i 500 --no-snps --ambiguity-usage all mobsuite_test/mob_predictions/${sra_accession}/${bin}.fasta
done
done
