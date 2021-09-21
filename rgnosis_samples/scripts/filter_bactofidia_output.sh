
#move to results
cd ../results

#get list of all ST131 strains
strains=$(cat ../results/sample_summaries_ST131.csv | sed 1d | cut -d ';' -f1)

#copy results of ST131 strains to new directory
for folder in assembly_graphs scaffolds stats/annotated; do
	
	#make new directories
	mkdir -p bactofidia_output_ST131/${folder}
	
	#define file extensions
	if [[ $folder = "scaffolds" ]]; then
		extension=.fna
	elif [[ $folder = "assembly_graphs" ]]; then
		extension=.gfa	
	fi

	for strain in $strains; do
		if [[ $folder = "stats/annotated" ]]; then
			mkdir -p bactofidia_output_ST131/stats/annotated/${strain}
			#in this case the strain is a directory and we want to copy all contents
			cp -r bactofidia_output/${folder}/${strain}/* bactofidia_output_ST131/${folder}/${strain}
		else
			cp -r bactofidia_output/${folder}/${strain}${extension} bactofidia_output_ST131/${folder}/${strain}${extension}
		fi
	done
done

