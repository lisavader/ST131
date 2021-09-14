#!/bin/bash

#set mode
while getopts :d: flag; do
        case $flag in
                d) dataset=$OPTARG;;
        esac
done

cd ../results/${dataset}

#make directory for holding the results
rm -rf predictions_spades
mkdir predictions_spades

#get a list of the files
if [[ $dataset = "ST131" ]]; then
	files=$(cat ../../../../ST131_ncbi_download/results/longread_ST131_sra_accessions)

elif [[ $dataset = "Ecoli" ]]; then
	files=$(cat ../../../../Ecoli_ncbi_download/results/benchmark_strains.csv)
fi

#create folder for temporary slurm scripts
rm -rf scripts_spades
mkdir scripts_spades

#create slurm scripts
for strain in $files
do
echo "#!/bin/bash
cd ../../../../../${dataset}_ncbi_download/results
plasmidspades.py --only-assembler -1 trimmed_sra_files/${strain}_R1*.fq -2 trimmed_sra_files/${strain}_R2*.fq -o ../../benchmarking/plasmid_reconstruction/results/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/${dataset}/predictions_spades/${strain}" > scripts_spades/${strain}
done

#Run the scripts
cd scripts_spades
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=4:30:00 --mem=20G ${slurm}
done
