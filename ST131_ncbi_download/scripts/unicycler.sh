#!/bin/bash

cd ~/data/genome_download/
sra_accessions=$(cat longread_ST131_sra_accessions)

for accession in $sra_accessions
do
unicycler --threads 20 -1 sra_files/${accession}_1.fastq -2 sra_files/${accession}_2.fastq -o ~/data/mobsuite_test/assemblies/${accession}
done
