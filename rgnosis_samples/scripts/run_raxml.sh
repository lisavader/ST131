#!/bin/bash

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate raxml

cd ../results/panaroo_output_all

#run RAxML with CAT model of rate heterogeneity
run_raxml(){
raxmlHPC-PTHREADS -m GTRCAT -s core_gene_alignment.aln -n ml_tree -N 20 -T 8 -p 1901
}

#add bootstrap values
draw_bootstrap_values(){
cat RAxML_result.ml_tree.RUN.* > bootstrap_trees
raxmlHPC -f b -m GTRCAT -t RAxML_bestTree.ml_tree -z bootstrap_trees -n bootstrap_tree
}

draw_bootstrap_values
