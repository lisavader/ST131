
cd plasmidspades_slurm_scripts
for slurm in SRR6985737 SRR5482170 SRR3465539 SRR13182991 SRR13182993
do
sbatch --time=6:00:00 --mem=20G ${slurm}
done
