#!/bin/bash

##create output directory
mkdir ../results/mlplasmids_predictions

##clone mlplasmids
cd ~/data #provide home directory
#git clone https://gitlab.com/sirarredondo/mlplasmids.git
cd mlplasmids

##run mlplasmids
for strain in ../ST131_repo/ST131_ncbi_download/results/shortread_assemblies_unicycler/*
do
name=$(basename $strain)
echo $name
Rscript scripts/run_mlplasmids.R $strain/assembly.fasta ../ST131_repo/benchmarking/mlplasmids/results/mlplasmids_predictions/${name}.tsv 1e-5 'Escherichia coli'
done
