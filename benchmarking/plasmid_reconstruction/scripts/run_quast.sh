#!/bin/bash

#activate conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

cd ../results

#set mode
while getopts :m: flag; do
        case $flag in
                m) mode=$OPTARG;;
        esac
done

#The way bins are named is different for spades and mobsuite, assign the correct one
if [[ $mode = "spades" ]];  then
	bin_name=$(echo '*component*')
else
	bin_name=$(echo 'plasmid*')
fi

#make directory for storing quast results
rm -rf quast_${mode}
mkdir quast_${mode}

#make directory for storing slurm scripts
rm -rf quast_scripts_${mode}
mkdir quast_scripts_${mode}

#put sra accessions in a variable
sra_accessions=$(cat ../../../ST131_ncbi_download/results/longread_ST131_sra_accessions)

for sra_accession in $sra_accessions
do
assembly_accession=$(grep ${sra_accession} ../../../ST131_ncbi_download/results/accessions_table.csv | cut -d , -f 1)      #find assembly accession
cd predictions_${mode}/${sra_accession}
all_bins=$(ls ${bin_name} | sed 's/.fasta//g')                                           #get names of all predicted plasmids for this strain
#for each plasmid, perform quast with the corresponding complete assembly as reference
cd ../..
for bin in $all_bins
do
echo "#!/bin/bash
quast -o quast_${mode}/${sra_accession}/${bin} -r ../../../ST131_ncbi_download/results/genomes/${assembly_accession}*genomic.fna -m 1000 -t 8 -i 500 --no-snps --ambiguity-usage all predictions_${mode}/${sra_accession}/${bin}.fasta" > quast_scripts_${mode}/${sra_accession}_${bin}
done
done

#Execute slurm scripts
cd quast_scripts_${mode}
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=1:00:00 --mem=20G $slurm
done
