#!/bin/bash

cd ~/data/genome_download
accessions=$(cat 2021_04_12_hybrid_ecoli_accessions)

for strain in $accessions:
do
esearch -db assembly -query ${strain} | elink -target nuccore | efetch -format fasta  > genomes/${strain}.fna
done

