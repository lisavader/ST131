#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --mem=32G
#SBATCH -c 8

#Set mode
while getopts :m: flag; do
        case $flag in
                m) mode=$OPTARG;;
        esac
done

#Activate conda for loading python libraries
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

##Run all scripts
#For parallelized scripts, I added a latency so that we only move on when the slurm scripts are finished

#Run plasmid reconstruction tools
if [[ $mode = mob* ]]; then
	bash run_mobsuite.sh -m $mode
	sleep 2h

elif [[ $mode = spades ]]; then
	bash run_plasmidspades.sh
	sleep 4h 30m
	#for plasmidspades, also separate the bins
	python separate_spades_bins.py	
fi

#In case of the EC 'cleaned' approach, remove predicted chromosomal contigs from bins
if [[ $mode = mob.*cleaned ]]; then
	python remove_contamination.py $mode
fi

#Run quast
bash run_quast.sh -m $mode
sleep 5m

#Gather quast results
python gather_quast_results.py $mode

#Add assembly accessions to alignment statistics file
bash add_assembly_accessions.sh -m $mode

#Remove slurm scripts folders
cd ../results
rm -r .*scripts.*
