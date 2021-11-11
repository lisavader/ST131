#!/bin/bash

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate raxml

cd ../results/panaroo_output_all

#run RAxML with CAT model of rate heterogeneity
raxmlHPC-PTHREADS -m GTRCAT -s core_gene_alignment.aln -n ml_tree -N 20 -T 8 -p 1901
