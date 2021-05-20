#!/bin/bash

cd ~/data/genome_download
sra_accessions=$(cat longread_ST131_sra_accessions)

for accession in $sra_accessions
do
fasterq-dump --split-files ${accession} -O sra_files   
done

