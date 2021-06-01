#!/bin/bash

cd ../results

mkdir busco_output
cd busco_output

accessions=$(ls ../bactofidia_output/scaffolds)

for acc in ${accessions}
do
name=$(basename ${acc} .fna)
busco -i ../bactofidia_output/scaffolds/${acc} -l enterobacterales_odb10 -o ${name} -m genome
done
