#!/bin/bash

#Author: Julian Paganini
#Modified by Lisa Vader

#1. Move to the directory that contains the busco_output
cd busco_output

#2. get a list of genomes
genomes=$(ls -I busco_downloads)

#3. Gather the results
for strain in $genomes
do
single_copy=$(cat ${strain}/run_enterobacterales_odb10/short_summary.txt | grep 'Complete and single' | cut -f 2)
duplicated=$(cat ${strain}/run_enterobacterales_odb10/short_summary.txt | grep 'Complete and duplicated' | cut -f 2) 
fragmented=$(cat ${strain}/run_enterobacterales_odb10/short_summary.txt | grep 'Fragmented' | cut -f 2) 
missing=$(cat ${strain}/run_enterobacterales_odb10/short_summary.txt | grep 'Missing' | cut -f 2)
echo ${strain},${single_copy},${duplicated},${fragmented},${missing} >> ../busco_results_summary.csv
done
