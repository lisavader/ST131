#Apparently some scripts didn't run for the first unicycler trimmed run
#Run them again

#activate conda
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

#run scripts again
cd ../results/scripts_unicycler_trimmed
strains=$(cat ../unitrim_tbd)
for strain in GCA_008275005.1_ASM827500v1
do
slurm=$(ls ${strain}*)
sbatch --time=10:00:00 --mem=30G $slurm
done

