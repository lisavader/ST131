#!/bin/bash

#activate conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate mobsuite

#set mode
while getopts :m:d: flag; do
        case $flag in
                m) mode=$OPTARG;;
		d) dataset=$OPTARG;;
        esac
done

cd ../results/${dataset}

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

#put accessions in a variable
accessions=$(ls predictions_${mode})

for accession in $accessions
do

if [[ $dataset = "ST131" ]]; then
	assembly_accession=$(grep ${accession} ../../../../ST131_ncbi_download/results/accessions_table.csv | cut -d , -f 1)      #find assembly accession
else
	assembly_accession=$accession
fi

cd predictions_${mode}/${accession}
all_bins=$(ls ${bin_name} | sed 's/.fasta//g')                                           #get names of all predicted plasmids for this strain
#for each plasmid, perform quast with the corresponding complete assembly as reference
cd ../..
for bin in $all_bins
do
echo "#!/bin/bash
#move back to results directory
cd ..
#run quast
quast -o quast_${mode}/${accession}/${bin} -r ../../../../${dataset}_ncbi_download/results/genomes/${assembly_accession}*genomic.fna -m 1000 -t 8 -i 500 --no-snps --ambiguity-usage all predictions_${mode}/${accession}/${bin}.fasta" > quast_scripts_${mode}/${accession}_${bin}
done
done

#Execute slurm scripts
cd quast_scripts_${mode}
jobs=$(ls)
for slurm in $jobs
do
sbatch --time=00:00:05 --mem=20G $slurm
done
