cd ../results/platon_predictions

files=$(ls)
for file in $files
do
cd $file
cat *chromosome.fasta | grep '>' | while read line
do
echo $line,"chromosome" >> ../../platon_all_results.csv
done
cat *plasmid.fasta | grep '>' | while read line
do
echo $line,"plasmid" >> ../../platon_all_results.csv
done
cd ..
done

