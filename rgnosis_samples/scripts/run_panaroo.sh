#!/bin/bash

#activate panaroo
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate panaroo

#move to results dir and make folder to store output
cd ../results
mkdir -p panaroo_output

##Pre-processing
#download mash refseq database
mkdir -p ../databases
#wget -P ../databases https://gembox.cbcb.umd.edu/mash/refseq.genomes.k21s1000.msh

#run pre-processing script
#panaroo-qc -t 3 --graph_type all -i bactofidia_output_ST131/stats/annotated/*/*.gff --ref_db ../databases/refseq.genomes.k21s1000.msh -o panaroo_output

##Run panaroo
panaroo -i bactofidia_output_ST131/stats/annotated/*/*.gff -o panaroo_output --clean-mode sensitive -a core --core_threshold 1
