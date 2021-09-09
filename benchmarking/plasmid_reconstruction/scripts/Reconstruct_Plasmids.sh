#SBATCH -J reconstruct_plasmids
#SBATCH --time=20:00:00
#SBATCH --mem=32G
#SBATCH -c 8

#set mode
while getopts :m: flag; do
        case $flag in
                m) mode=$OPTARG;;
        esac
done

#activate conda for loading python libraries
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

##run all scripts

#Run plasmid reconstruction tools
if [[ $mode = mob* ]]; then
	bash run_mobsuite.sh -m $mode
elif [[ $mode = spades ]]; then
	bash run_plasmidspades.sh
fi

#sleep to wait for mobsuite scripts to finish
sleep 2h
bash quast_mobsuite_bac.sh
python gather_quast_results_mob_bac.py
bash add_assembly_accessions.shi
