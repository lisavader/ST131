cd ../results

#set tab character
T=$(printf '\t')
#write output file header
echo "'Assembly Accession'$T'SRA Accession'$T'Prob_Chromosome'$T'Prob_Plasmid'$T'Prediction'$T'Contig_name'$T'Contig_length'" > mlplasmids_all_results.tsv

#move to predictions directory
cd mlplasmids_predictions

##loop over files
files=$(ls)
for file in $files
do
#add sra and assembly accessions to each line
cat $file | sed '1d' | while read line
do
sra_accession=$(basename $file .tsv)
assembly_accession=$(cat ../../../../ST131_ncbi_download/results/accessions_table.csv | grep $sra_accession | cut -d , -f 1)
echo "$assembly_accession$T$sra_accession$T$line" >> ../mlplasmids_all_results.tsv		#append output file
done
done
