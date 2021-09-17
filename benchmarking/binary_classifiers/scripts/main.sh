
#specify input directory (path from binary_classifiers)
path=$(echo '../../Ecoli_ncbi_download/shortread_assemblies_bactofidia')

#specify output name
output_file=$(echo 'output_Ecoli_bac.csv')

#run binary classifiers
for tool in mlplasmids platon plascope rfplasmid; do
bash run_${tool}.sh -i $path
done

#gather results
bash gather_results.sh -o $output_file
