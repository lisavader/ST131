
cd ../../results/plasmidspades_slurm_scripts
for slurm in SRR11949021
do
sbatch --time=6:00:00 --mem=20G ${slurm}
done
