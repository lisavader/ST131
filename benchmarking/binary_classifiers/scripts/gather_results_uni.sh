#!/bin/bash

#delete previous output file
#rm -f ../results/${output_file}

##MLPLASMIDS
gather_mlplasmids(){
for file in ../results/mlplasmids_predictions/*
do
tail -n +2 $file | while read line
do
prediction=$(echo $line | cut -d' ' -f3 | sed 's/"//g')
contig=$(echo $line | cut -d' ' -f4 | sed 's/"//g')
echo $contig,${prediction,,},mlplasmids >> ../results/${output_file}
done
done
}

##PLASCOPE
gather_plascope(){
cd ../results/plascope_predictions

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
echo ${strain}_${node},$classification,"plascope" >> ../../${output_file}

done

cd ..
done

cd ..
}

##PLATON
gather_platon(){
cd ../results/platon_predictions

files=$(ls)
for file in $files
do
cd $file

#grab chromosomal contigs
cat *chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo ${file}_$contig,"chromosome","platon" >> ../../${output_file}
done
#grab plasmid contigs
cat *plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo ${file}_$contig,"plasmid","platon" >> ../../${output_file}
done

cd ..
done

cd ..
}

#RFPLASMID
gather_rfplasmid(){
cd ../results/rfplasmid_predictions

files=$(ls)
for file in $files
do
cd $file

cat prediction.csv | sed '1d' | while read line
do
contig=$(echo $line | cut -d, -f5 | sed 's/"//g' | cut -d' ' -f1)
if [[ $line = *'"p"'* ]]; then
echo ${file}_$contig,"plasmid","rfplasmid" >> ../../${output_file}
else
echo ${file}_$contig,"chromosome","rfplasmid" >> ../../${output_file}
fi
done

cd ..

done
}

while getopts :o: flag; do
	case $flag in
		o) output_file=$OPTARG;;
	esac
done

gather_plascope
gather_platon
gather_rfplasmid
