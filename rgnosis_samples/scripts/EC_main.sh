#!/bin/bash

#specify input directory (path from rgnosis_samples)
path=$(echo 'results/bactofidia_output_ST131/scaffolds')

#specify output name
output_file=$(echo 'EC_output.csv')

#run binary classifiers
run_binary_classifiers(){
for tool in plascope platon rfplasmid; do
sbatch -c 8 --mem 50G --time 4:00:00 --gres=tmpspace:50G ../../benchmarking/binary_classifiers/scripts/run_${tool}.sh -i $path
done
}

#gather results
gather_results(){
bash ../../benchmarking/binary_classifiers/scripts/gather_results.sh -o ../results/$output_file
}

#combine results
combine_results(){
Rscript ../../benchmarking/binary_classifiers/scripts/combine_results.R
}

#Use this result to select all plasmid contigs
select_plasmid_contigs(){
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite
python ../../benchmarking/plasmid_reconstruction/scripts/select_plasmid_contigs.py dataset rgnosis
}

#specify which parts to run:
select_plasmid_contigs
