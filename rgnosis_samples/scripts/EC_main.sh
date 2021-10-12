#!/bin/bash

#specify input directory (path from rgnosis_samples)
path=$(echo 'results/bactofidia_output_ST131/scaffolds')

#specify output name
output_file=$(echo 'EC_output.csv')

#run binary classifiers
for tool in rfplasmid; do
sbatch -c 8 --mem 50G --time 4:00:00 --gres=tmpspace:50G ../../benchmarking/binary_classifiers/scripts/run_${tool}.sh -i $path
done

#gather results
#sleep 1h
#bash ../../benchmarking/binary_classifiers/scripts/gather_results.sh -o ../results/$output_file

