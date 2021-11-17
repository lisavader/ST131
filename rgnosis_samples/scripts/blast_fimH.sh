#!/bin/bash

#I used the database from fimtyper (fimH.fsa)
build_database(){
cd ../databases
makeblastdb -dbtype nucl -in fimH.fsa -out fimH_database -blastdb_version 4
}

blast_fimH(){
cd ../results
mkdir -p blast_fimH

for assembly in bactofidia_output_all/scaffolds/*.fasta; do
strain=$(basename $assembly .fasta)
blastn -db ../databases/fimH_database -query $assembly -out blast_fimH/${strain}.out
done
}

gather_results(){
cd ../results/blast_fimH
rm all_fimH_types.csv

for result in *.out; do
strain=$(basename $result .out)
#only keep perfect matches (the fimH gene is 904 bp long)
fimH_allele=$(cat $result | grep fimH | grep ' 904' | cut -d ' ' -f1)
#if no matches are found at all, result is 'no' (when there are matches, but none are perfect there will simply be an empty result)
fimlines=$(cat $result | grep fimH | wc -l)
if [[ $fimlines = 2 ]]; then
	fimH_allele='no'
fi
echo $strain,$fimH_allele >> all_fimH_types.csv
done
}

#Run:
gather_results
