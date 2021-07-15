cd ../results/plascope_predictions

files=$(ls)
for file in $files
do
cd $file

#grab chromosmal contigs
cat PlaScope_predictions/*chromosome.fasta | grep '>' | while read line
do
echo $line,"chromosome" >> ../../plascope_all_results.csv
done
#grab plasmid contigs
cat PlaScope_predictions/*plasmid.fasta | grep '>' | while read line
do
echo $line,"plasmid" >> ../../plascope_all_results.csv
done
#grab unclassified contigs
cat PlaScope_predictions/*unclassified.fasta | grep '>' | while read line
do
echo $line,"unclassified" >> ../../plascope_all_results.csv
done

cd ..
done

