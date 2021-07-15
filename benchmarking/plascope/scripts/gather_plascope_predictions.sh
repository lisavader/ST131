cd ../results/plascope_predictions

#remove previous output file (if existing)
rm ../plascope_all_results.csv

#for each file..
files=$(ls)
for file in $files
do
strain=$(basename $file _PlaScope)

#go to extended result file to find node (contig ID) and class nr
cd $file
cat Centrifuge_results/*extendedresult | sed '1d' | while read line
do
node=$(echo $line | cut -d ' ' -f1)
class_nr=$(echo $line | cut -d ' ' -f3)
#translate class nr to classification (i.e. 2 = chromosome, 3 = plasmid, 0 / 1 = unclassified)
if [ $class_nr == '3' ]
then
	classification="plasmid"
elif [ $class_nr == '2' ]
then
	classification="chromosome"
else
	classification="unclassified"
fi
#write to file
echo $strain,$node,$classification >> ../../plascope_all_results.csv
done
cd ..
done
