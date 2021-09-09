#Author: Julian Paganini
#Adjusted by Lisa Vader

cd ../results

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

#0. set mode
while getopts :m: flag; do
        case $flag in
                m) mode=$OPTARG;;
        esac
done

#1. create directory to store slurm jobs
rm -rf scripts_$mode
mkdir scripts_$mode

#2. Create directory to store mob-results
rm -rf predictions_$mode
mkdir predictions_$mode

#3. Get a list of strain names
accessions=$(cat ../../../ST131_ncbi_download/results/longread_ST131_sra_accessions)


#4- create sbatch scripts - this part will create one individual sbatch script for running MOB for the samples
for strain in $accessions
do

if [[ $mode = "mob_bac" | $mode = "mob_bac_cleaned" ]];  then
        path=$(echo "shortread_assemblies_bactofidia/scaffolds/${strain}.fna")
fi

if [[ $mode = "mob_uni" ]];  then
        path=$(echo "shortread_assemblies_unicycler/${strain}/assembly.fasta")
fi

if [[ $mode = "mob_unitrim" ]];  then
        path=$(echo "shortread_assemblies_unicycler_trimmed/${strain}/assembly.fasta")
fi

if [[ $mode = "mob_bac_filtered" ]]; then
	path=$(echo "shortread_assemblies_bactofidia/plasmid_scaffolds2/${strain}.fna")
fi

echo "#!/bin/bash
#1. Move to the directory that will contain the mob predictions
cd ../predictions_${mode}
#2. Run MOB-suite
mob_recon --infile ../../../../ST131_ncbi_download/results/${path} --outdir ${strain}" > scripts_${mode}/${strain}.sh
done

#5- Run the sbatch scripts
cd scripts_${mode}
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=2:00:00 --mem=5G ${slurm}
done
