#!/bin/bash

##create output directory
mkdir ../results/mlplasmids_predictions

##clone mlplasmids
cd ~/data #provide home directory
#git clone https://gitlab.com/sirarredondo/mlplasmids.git
cd mlplasmids

##run mlplasmids
for file in ../ST131_repo/ST131_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds/*.fna
do
name=$(basename $file .fna)
Rscript scripts/run_mlplasmids.R $file ../ST131_repo/benchmarking/mlplasmids/results/mlplasmids_predictions/${name}.tsv 1e-5 'Escherichia coli'
done
