#!/bin/bash

#activate conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate quast

cd ../../../Ecoli_ncbi_download/results
: '
#make directory for storing quast scripts and results
mkdir -p quast_output_bactofidia_contigs/ambiguity_all
mkdir -p quast_scripts

##Use quast to align contigs to reference genome
for file in shortread_assemblies_bactofidia/scaffolds/*.fasta
do
name=$(basename $file .fasta)
ref_name=$(echo $name | sed 's/-/_/g')    
echo "#!/bin/bash
quast -o ../quast_output_bactofidia_contigs/ambiguity_all/${name} -r ../genomes/${ref_name}*genomic.fna -m 1000 -t 8 -i 500 --fast --ambiguity-usage all ../$file" > quast_scripts/${name}.sh
done

cd quast_scripts
for script in $(ls); do
sbatch -c 8 --time 00:10:00 --mem 5G $script
done

#wait for scripts to finish
sleep 15m
'
##Select true alignments
cd quast_output_bactofidia_contigs/ambiguity_all/

strains=$(ls)

for strain in $strains
do
cat ${strain}/contigs_reports/all_alignments_*.tsv | grep 'True' >> ../../bactofidia_all_true_alignments.tsv
done

