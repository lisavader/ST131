#!/bin/bash

#activate conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

cd ../results

#make directory for storing quast results
mkdir quast_output3

#put sra accessions in a variable
sra_accessions=$(ls mob_predictions3)

for sra_accession in $sra_accessions
do
assembly_accession=$(grep ${sra_accession} ../../../ST131_ncbi_download/results/accessions_table.csv | cut -d , -f 1)      #find assembly accession
cd mob_predictions3/${sra_accession}
all_bins=$(ls plasmid* | sed 's/.fasta//g')                                           #get names of all predicted plasmids for this strain
cd ../..
#for each plasmid, perform quast with the corresponding complete assembly as reference
for bin in $all_bins
do
quast -o quast_output3/${sra_accession}/${bin} -r ../../../ST131_ncbi_download/results/genomes/${assembly_accession}*genomic.fna -m 1000 -t 8 -i 500 --no-snps --ambiguity-usage all mob_predictions3/${sra_accession}/${bin}.fasta
done
done
