#!/bin/bash
#SBATCH --time=10:00:00
#SBATCH --mem=5G
#SBATCH -c 8

##Set flags
#Provide the mode with m
#Add an s flag if reconstruction results are already present and you want to skip this step
while getopts :sd:m: flag; do
        case $flag in
		d) dataset=$OPTARG;;
                m) mode=$OPTARG;;
		s) skip_reconstruction='true'
        esac
done

echo "Dataset =" $dataset
echo "Mode =" $mode

#Activate conda for mobsuite and loading python libraries
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

##Run all scripts
#For parallelized scripts, I added a latency so that we only move on when the slurm scripts are finished

#In case of the EC 'filtered' approach, assembly files are filtered beforehand so that only the plasmid contigs remain
if [[ $mode = *filtered ]]; then
	echo "Filtering assembly files..."
	python select_plasmid_contigs.py $dataset $mode
fi

#Run plasmid reconstruction tools
#If mode is 'cleaned', I dont run this step because there is no difference in the mob reconstruction.
#This means that mob_bac or mob_uni results should exist already before running 'cleaned' mode.
if [[ $skip_reconstruction = true || $mode = *cleaned ]]; then
	echo "Skipping reconstruction step..."
	:

elif [[ $mode = spades ]]; then
	echo "Running plasmidspades..."
	bash run_plasmidspades.sh -d $dataset
	sleep 4h 30m
	#for plasmidspades, also separate the bins
	python separate_spades_bins.py -d $dataset

elif [[ $mode = mob* ]]; then
	echo "Running mobsuite..."
	bash run_mobsuite.sh -d $dataset -m $mode
	sleep 1h
fi

#In case of the EC 'cleaned' approach, remove predicted chromosomal contigs from bins
if [[ $mode = *cleaned ]]; then
	echo "Removing chromosomal contamination from bins..."
	python remove_contamination.py $dataset $mode
fi

#Run quast
echo "Running quast..."
bash run_quast.sh -d $dataset -m $mode
sleep 30m

#Gather quast results
echo "Gathering quast results..."
python gather_quast_results.py $dataset $mode

#For ST131: Add assembly accessions to alignment statistics file
if [[ $dataset = ST131 ]]; then
	echo "Adding assembly accessions..."
	bash add_assembly_accessions.sh -m $mode
fi

#Remove slurm scripts folders (optional)
cd ../${dataset}/results
#rm -r *scripts*
