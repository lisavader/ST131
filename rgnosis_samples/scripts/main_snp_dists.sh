#!/bin/bash

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate snp_tree

#Concatenate alignment files from panaroo
concatenate_alignments(){
python combine_core_alignments.py
}

#Calculate distances with snp-dists
run_snp-dists(){
cd ../results/panaroo_output_all
snp-dists core_gene_alignment.aln > core_snp_dists.tsv
}

#Run these parts:
#concatenate_alignments
#run_snp-dists

Rscript build_snp_tree.R ../results/panaroo_output_all/core_snp_dists.tsv ../results/panaroo_output_all/nj_snp_tree.newick

