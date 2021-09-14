
#build directories
#mkdir ../results/raw_reads

#get GCA accession nr of benchmarking strains
cat ../results/benchmark_strains.csv | while read line; do
	accession=$(echo $line | cut -d '_' -f2)

	#copy raw reads
	raw_reads_files=$(ls /hpc/archive/dla_mm/jpaganini/recovering_ecoli_plasmids/2020_08_30_run_predictions/data/sra_files | grep $accession)
	for file in $raw_reads_files; do
		cp /hpc/archive/dla_mm/jpaganini/recovering_ecoli_plasmids/2020_08_30_run_predictions/data/sra_files/${file} ../results/raw_reads
	done

done

