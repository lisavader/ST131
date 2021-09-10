#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --mem=32G
#SBATCH -c 8

#Set mode
while getopts :sm: flag; do
        case $flag in
                m) mode=$OPTARG;;
		s) skip_reconstruction='true'
        esac
done

#Activate conda for loading python libraries
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

##Run all scripts
#For parallelized scripts, I added a latency so that we only move on when the slurm scripts are finished

#Run plasmid reconstruction tools
#If mode is 'cleaned', I dont run this step because there is no difference in the mob reconstruction.
#This means that mob_bac or mob_uni results should exist already before running 'cleaned' mode.
if [[ $skip_reconstruction = true || $mode = mob.*cleaned ]]; then
	:

elif [[ $mode = spades ]]; then
	echo "Running plasmidspades..."
	bash run_plasmidspades.sh
	sleep 4h 30m
	#for plasmidspades, also separate the bins
	python separate_spades_bins.py	

elif [[ $mode = mob* ]]; then
	echo "Running mobsuite..."
	bash run_mobsuite.sh -m $mode
	sleep 30m
fi

#In case of the EC 'cleaned' approach, remove predicted chromosomal contigs from bins
if [[ $mode = mob.*cleaned ]]; then
	echo "Removing chromosomal contamination from bins..."
	python remove_contamination.py $mode
fi

#Run quast
echo "Running quast..."
bash run_quast.sh -m $mode
sleep 5m

#Gather quast results
echo "Gathering quast results..."
python gather_quast_results.py $mode

#Add assembly accessions to alignment statistics file
echo "Adding assembly accessions..."
bash add_assembly_accessions.sh -m $mode

#Remove slurm scripts folders
cd ../results
rm -r .*scripts.*
