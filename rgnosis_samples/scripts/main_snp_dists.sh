#!/bin/bash

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate snp_tree

#Concatenate alignment files from panaroo
concatenate_alignments(){
python combine_core_alignments.py
}

#Calculate distances with snp-dists
run_snp-dists(){
cd ../results/panaroo_output/aligned_gene_sequences
snp-dists all_aligned_genes.aln.fas > all_snp_dists.tsv
}

#Run these parts:
concatenate_alignments
run_snp-dists
