#Trimmed or non-trimmed reads?
while getopts :t flag; do
        case $flag in
                t) trim='_trimmed'		
        esac
done

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

cd ../results
mkdir shortread_assemblies_unicycler${trim} 
mkdir scripts_unicycler${trim}

accessions=$(cat benchmark_strains.csv)

for sample in $accessions
do
echo "#!/bin/bash
cd ..
unicycler --threads 20 -1 raw_reads/${sample}_R1* -2 raw_reads/${sample}_R2* -o shortread_assemblies_unicycler${trim}/${sample}" > scripts_unicycler${trim}/${sample}.sh
done

cd scripts_unicycler${trim}
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=10:00:00 --mem=30G $slurm
done

