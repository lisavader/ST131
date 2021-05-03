#!/bin/bash

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

cd ~/data
mkdir mobsuite_test/quast_output
sra_accessions=$(cat genome_download/longread_ST131_sra_accessions)

for sra_accession in $sra_accessions
do
assembly_accession=$(esearch -db sra -query ${sra_accession} | elink -target biosample | elink -target assembly | esummary | xmllint --xpath "string(//Genbank)" -)
cd mobsuite_test/mob_predictions/${sra_accession}
all_bins=$(ls plasmid* | sed 's/.fasta//g')
cd ~/data
for bin in $all_bins
do
quast -o mobsuite_test/quast_output/${assembly_accession}:${sra_accession}/${bin} -r genome_download/genomes/${assembly_accession}*genomic.fna -m 1000 -t 8 -i 500 --no-snps --ambiguity-usage all mobsuite_test/mob_predictions/${sra_accession}/${bin}.fasta
done
done
