cd ../results

#remove previous output (if existing)
rm multi_plasmid_bins.csv

#save bin names of both methods
bin_names_cleaned=$(cat multiple_plasmids.csv | grep cleaned | cut -d , -f1 | tr -d '"')
bin_names_EC=$(cat multiple_plasmids.csv | grep contigs | cut -d , -f1 | tr -d '"')

for name in $bin_names_cleaned
do
method=$(echo "cleaned")				#assign method
sra=$(echo $name | cut -d _ -f 1)			#split name into sra and bin
bin_name=$(echo $name | cut -d _ -f 2,3)
#go to the mob result of each bin and grab contig names
contigs=$(cat ../../mobsuite_clean/results/mob_predictions_clean/${sra}/${bin_name}* | grep '>' | tr -d '>')
for contig in $contigs
do
#write all info to file
echo $contig,$bin_name,$sra,$method >> multi_plasmid_bins.csv
done
done

for name in $bin_names_EC
do
method=$(echo "run_on_plasmid_contigs")
sra=$(echo $name | cut -d _ -f 1)
bin_name=$(echo $name | cut -d _ -f 2,3)
contigs=$(cat ../../mobsuite_EC/results/mob_predictions/${sra}/${bin_name}* | grep '>' | tr -d '>')
for contig in $contigs
do
echo $contig,$bin_name,$sra,$method >> multi_plasmid_bins.csv
done
done

