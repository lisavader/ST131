#!/bin/bash

#specify input directory (path from binary_classifiers)
path=$(echo '../../Ecoli_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds')

#specify output name
output_file=$(echo 'output_Ecoli_bac.csv')

#change file extensions of input from .fna to .fasta if necessary (otherwise rfplasmid does not run)
files_dir=$(echo '../../../Ecoli_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds/')
for file in $(ls $files_dir)
do
new_name=$(echo $file | sed 's/.fna/.fasta/')
cp ${files_dir}${file} ${files_dir}${new_name}
done

#run binary classifiers
for tool in mlplasmids platon plascope rfplasmid; do
sbatch -c 8 --mem 10G --time 4:00:00 run_${tool}.sh -i $path
done

#gather results
sleep 2h
bash gather_results.sh -o $output_file

