

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

#0. set mode
while getopts :m:d: flag; do
        case $flag in
		d) dataset=$OPTARG;;
                m) mode=$OPTARG;;
        esac
done
cd ../results/${dataset}

#1. create directory to store slurm jobs
rm -rf scripts_$mode
mkdir scripts_$mode

#2. Create directory to store mob-results
rm -rf predictions_$mode
mkdir predictions_$mode

#3. Get a list of strain names
if [[ $dataset = "ST131" ]]; then
	accessions=$(cat ../../../../ST131_ncbi_download/results/longread_ST131_sra_accessions)

elif [[ $dataset = "Ecoli" ]]; then
	accessions=$(cat ../../../../Ecoli_ncbi_download/results/benchmark_strains.csv)
fi

#4- create sbatch scripts - this part will create one individual sbatch script for running MOB for the samples
for strain in $accessions
do

if [[ $mode = "mob_bac" ]];  then
	name=$(echo ${strain} | sed 's/_/-/g')
        path=$(echo "shortread_assemblies_bactofidia/scaffolds/${name}.fasta")

elif [[ $mode = "mob_uni" ]];  then
        path=$(echo "shortread_assemblies_unicycler/${strain}/assembly.fasta")

elif [[ $mode = "mob_unitrim" ]];  then
        path=$(echo "shortread_assemblies_unicycler_trimmed/${strain}/assembly.fasta")

elif [[ $mode = "mob_bac_filtered" ]]; then
	name=$(echo ${strain} | sed 's/_/-/g')
	path=$(echo "shortread_assemblies_bactofidia/scaffolds/predicted_plasmid_contigs/${name}.fasta")

elif [[ $mode = "mob_uni_filtered" ]]; then
	path=$(echo "shortread_assemblies_unicycler/predicted_plasmid_contigs/${strain}")
fi

echo "#!/bin/bash
#1. Move to the directory that will contain the mob predictions
cd ../predictions_${mode}
#2. Run MOB-suite
mob_recon --infile ../../../../../${dataset}_ncbi_download/results/${path} --outdir ${strain}" > scripts_${mode}/${strain}.sh
done

#5- Run the sbatch scripts
cd scripts_${mode}
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=2:00:00 --mem=5G ${slurm}
done
