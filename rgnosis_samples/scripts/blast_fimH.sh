#!/bin/bash

#I used the database from fimtyper (fimH.fsa)
build_database(){
cd ../databases
makeblastdb -dbtype nucl -in fimH.fsa -out fimH_database -blastdb_version 4
}

blast_fimH(){
cd ../results
mkdir -p blast_fimH

for assembly in bactofidia_output_ST131/scaffolds/*.fasta; do
strain=$(basename $assembly .fasta)
blastn -db ../databases/fimH_database -query $assembly -out blast_fimH/${strain}.out
done
}

gather_results(){
cd ../results/blast_fimH

for result in *.out; do
strain=$(basename $result .out)
fimH_allele=$(cat $result | grep fimH | sed '1d' | head -n 1 | cut -d ' ' -f1)
echo $strain,$fimH_allele >> all_fimH_types.csv
done
}

#Run:
gather_results
