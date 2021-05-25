#!/bin/bash

mkdir busco_output
cd busco_output

accessions=$(ls ../assemblies)

for acc in ${accessions}
do
busco -i ../assemblies/${acc}/assembly.fasta -l enterobacterales_odb10 -o ${acc} -m genome
done
