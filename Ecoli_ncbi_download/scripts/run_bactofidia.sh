#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=40G
#SBATCH -c 8

cd ../../../bactofidia
ln -s ../ST131_repo/Ecoli_ncbi_download/results/raw_reads/* .
bash ./bactofidia.sh *.fastq.gz
