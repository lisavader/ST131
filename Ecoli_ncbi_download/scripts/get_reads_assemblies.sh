
#build directories
#mkdir ../results/raw_reads
mkdir ../results/trimmed_sra_files
mkdir ../results/genomes

#get GCA accession nr of benchmarking strains
#For all strains in the list benchmark_strains.csv, it has been checked that they are not present in reference databases / training datasets of mlplasmids, PlaScope, Platon or RFPlasmid.
cat ../results/benchmark_strains.csv | while read line; do
	accession=$(echo $line | cut -d '_' -f2)

	#copy raw reads
	raw_reads_files=$(ls /hpc/archive/dla_mm/jpaganini/recovering_ecoli_plasmids/2020_08_30_run_predictions/data/sra_files | grep $accession)
	for file in $raw_reads_files; do
		cp /hpc/archive/dla_mm/jpaganini/recovering_ecoli_plasmids/2020_08_30_run_predictions/data/sra_files/${file} ../results/raw_reads
	done

	#copy trimmed reads
	trimmed_reads_files=$(ls /hpc/dla_mm/jpaganini/data/ecoli_binary_classifier/2021_07_test_plasmid_ec/2021_07_28_prepare_dataset/data/trimmed_reads | grep $accession)
	for file in $trimmed_reads_files; do
		cp /hpc/dla_mm/jpaganini/data/ecoli_binary_classifier/2021_07_test_plasmid_ec/2021_07_28_prepare_dataset/data/trimmed_reads/${file} ../results/trimmed_sra_files
	done

	#copy reference genomes
	ref_file=$(ls /hpc/dla_mm/jpaganini/data/ecoli_binary_classifier/2021_07_test_plasmid_ec/2021_08_16_benchmarking_ec/data/reference_genomes | grep $accession)
	cp /hpc/dla_mm/jpaganini/data/ecoli_binary_classifier/2021_07_test_plasmid_ec/2021_08_16_benchmarking_ec/data/reference_genomes/${ref_file} ../results/genomes
done

#Gzip raw reads because bactofidia needs it
mkdir gzip_scripts
for sample in  ../results/raw_reads/*.fastq; do
	name=$(basename $sample)
	echo "#!/bin/bash 
gzip ../${sample}" > gzip_scripts/${name}.sh 
done
cd gzip_scripts
for job in $(ls *.sh); do
	sbatch --mem 10G --time 00:30:00 $job
done

