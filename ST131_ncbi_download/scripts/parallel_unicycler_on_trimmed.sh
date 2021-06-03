source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

cd ../results

files=$(cat longread_ST131_sra_accessions)

mkdir shortread_assemblies_unicycler_trimmed
mkdir unitrim_slurm_jobs

for sample in $files
do
echo "#!/bin/bash
cd ..
unicycler --threads 20 -1 trimmed_sra_files/${sample}_R1*.fq -2 trimmed_sra_files/${sample}_R2*.fq -o shortread_assemblies_unicycler_trimmed/${sample}" > unitrim_slurm_jobs/${sample}.sh
done

cd unitrim_slurm_jobs
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=10:00:00 --mem=30G $slurm
done
