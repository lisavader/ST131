#!/bin/bash

#Only part of all rgnosis E.coli strains has been assembled (those in ST131 and 3rd_run)
#We will assemble those that have not been assembled yet

cd ../results

find_strains(){
#Save strains that still have to be assembled in a list

#remove old file
rm strains_to_be_assembled.txt

all_strains=$(cat all_ecoli_rgnosis.txt)
assembled_strains=$(ls bactofidia_output/scaffolds | sed 's/.fna//g')

#For every strain, check if it has been assembled
total_assembled=0

for strain in $all_strains; do
if [[ $assembled_strains =~ $strain ]]; then
#If yes, add to count
	((total_assembled++))
else
#If no, add to file of to be assembled strains
	echo $strain >> strains_to_be_assembled.txt
fi
done
}


show_summary(){
#Print number of strains that are assembled / not assembled

not_assembled=$(cat strains_to_be_assembled.txt | wc -l)

echo $total_assembled "strains are already assembled."
echo $not_assembled "strains should still be assembled."
}

get_raw_reads(){
#Transfer raw reads from the archive

mkdir -p raw_reads

strains=$(cat strains_to_be_assembled.txt)
for strain in $strains; do
#if reads aren't there yet, copy them
[[ $(ls raw_reads) =~ $strain ]] || cp /hpc/archive/dla_mm/jpaganini/reads_rgnosis/all_reads/${strain}* raw_reads && echo $strain
done
}

run_bactofidia(){
#run bactofidia on raw reads
cd ../../bactofidia
ln -s rgnosis_samples/results/raw_reads/*.gz .
sbatch --time 48:00:00 --mem 32G -c 8 bactofidia.sh ALL
cd rgnosis_samples/results
}

merge_all_assemblies(){
#Add newly assembled and previously assembled strains in one dir

all_strains=$(cat all_ecoli_rgnosis.txt)

#copy results of all strains to new directory
for folder in stats/annotated; do

        #make new directories
        mkdir -p bactofidia_output_all/${folder}

        #define file extensions
        if [[ $folder = "scaffolds" ]]; then
                extension=.fna
        elif [[ $folder = "assembly_graphs" ]]; then
                extension=.gfa
        fi

        for strain in $all_strains; do
	failed=0
		for output_folder in bactofidia_output bactofidia_output_add_Ecoli; do
                	if [[ $folder = "stats/annotated" ]]; then
                        	mkdir -p bactofidia_output_all/stats/annotated/${strain}
                        	#in this case the strain is a directory and we want to copy all contents
				cp -r ${output_folder}/${folder}/${strain}/* bactofidia_output_all/${folder}/${strain} || ((failed++))
			else
                        	cp -r ${output_folder}/${folder}/${strain}${extension} bactofidia_output_all/${folder}/${strain}${extension} || ((failed++))
                	fi
		done
	#If searches in both output folders failed, output an error
	if [[ $failed > 1 ]]; then
		echo "Error:" $strain "not found in" $folder
	else
		echo $strain "was found"
	fi

        done
done
}

merge_resfinder(){
cat bactofidia_output/stats/ResFinder.tsv > bactofidia_output_all/stats/ResFinder.tsv
tail -n +2 bactofidia_output_add_Ecoli/stats/ResFinder.tsv >> bactofidia_output_all/stats/ResFinder.tsv
}

#Specify which functions to run:
find_strains
show_summary
get_raw_reads
run_bactofidia
merge_all_assemblies
merge_resfinder

