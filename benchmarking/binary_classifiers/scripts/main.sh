
#specify input directory (path from binary_classifiers)
path=$(../../Ecoli_ncbi_download/shortread_assemblies_bactofidia)

#run binary classifiers
for tool in mlplasmids platon plascope rfplasmid; do
bash run_${tool}.sh -i $path
done

#gather results
bash gather_results.sh_
