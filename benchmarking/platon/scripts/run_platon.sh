#!/bin/bash

#create conda environment for platon
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda create --name platon -c bioconda platon
conda activate platon

#download database
mkdir ../data
cd ../data
#wget https://zenodo.org/record/4066768/files/db.tar.gz
#tar -xzf db.tar.gz
rm db.tar.gz

#run platon
mkdir ../results/platon_predictions
cd ../results/platon_predictions

for strain in  ../../../../ST131_ncbi_download/results/shortread_assemblies_unicycler/*
do
name=$(basename $strain)
echo $name
platon --db ../../data/db --output $name --threads 8 --verbose $strain/assembly.fasta
done
