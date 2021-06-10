#!/bin/bash

#activate conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate quast

cd ../results

#make directory for storing quast results
mkdir quast_output_bactofidia_contigs

#find assembly accession and run quast with assembly as reference
for file in shortread_assemblies_bactofidia/scaffolds/*.fna
do
name=$(basename $file .fna)
assembly_accession=$(grep $name  accessions_table.csv | cut -d , -f 1)      
quast -o quast_output_bactofidia_contigs/${name} -r genomes/${assembly_accession}*genomic.fna -m 1000 -t 8 -i 500 --fast --ambiguity-usage one $file
done
