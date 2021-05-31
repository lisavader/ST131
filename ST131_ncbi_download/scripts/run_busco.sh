#!/bin/bash

#define directory name
assemblies_dir=shortread_assemblies_unicycler

cd ../results

mkdir busco_output
cd busco_output

accessions=$(ls $assemblies_dir)

for acc in ${accessions}
do
busco -i ../$assemblies_dir/${acc}/assembly.fasta -l enterobacterales_odb10 -o ${acc} -m genome
done
