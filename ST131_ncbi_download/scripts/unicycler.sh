#!/bin/bash

cd ../results

mkdir shortread_assemblies_unicycler

sra_accessions=$(cat longread_ST131_sra_accessions)

for accession in $sra_accessions
do
unicycler --threads 20 -1 sra_files/${accession}_1.fastq -2 sra_files/${accession}_2.fastq -o shortread_assemblies_unicycler/${accession}
done
