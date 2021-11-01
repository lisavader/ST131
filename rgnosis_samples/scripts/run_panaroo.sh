#!/bin/bash

#activate panaroo
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate panaroo

#move to results dir and make folder to store output
cd ../results

##Pre-processing
#download mash refseq database
mkdir -p ../databases
#wget -P ../databases https://gembox.cbcb.umd.edu/mash/refseq.genomes.k21s1000.msh

#run pre-processing script
preprocessing(){
dataset=$1
panaroo-qc -t 3 --graph_type all -i bactofidia_output_${dataset}/stats/annotated/*/*.gff --ref_db ../databases/refseq.genomes.k21s1000.msh -o panaroo_output_${dataset}
}

##Run panaroo
run_panaroo(){
dataset=$1
panaroo -i bactofidia_output_ST131/stats/annotated/*/*.gff -o panaroo_output_${dataset} --clean-mode sensitive
}

##Core gene alignment
align_core_genes(){
dataset=$1
panaroo-msa -o panaroo_output_${dataset} -a core --core_threshold 0.999
run_panaroo all
}

align_core_genes all
