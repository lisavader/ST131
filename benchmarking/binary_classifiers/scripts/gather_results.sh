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
cd $file

#grab chromosmal contigs
cat PlaScope_predictions/*chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","plascope" >> ../../${output_file}
done
#grab plasmid contigs
cat PlaScope_predictions/*plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","plascope" >> ../../${output_file}
done
#grab unclassified contigs
cat PlaScope_predictions/*unclassified.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"unclassified","plascope" >> ../../${output_file}
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
echo $contig,"chromosome","platon" >> ../../${output_file}
done
#grab plasmid contigs
cat *plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","platon" >> ../../${output_file}
done

cd ..
done

cd ..
}

#RFPLASMID
gather_rfplasmid(){
dir=$(ls -Art ../results/rfplasmid_predictions | tail -n 1)
tail -n +2 ../results/rfplasmid_predictions/$dir/prediction.csv | while read line
do
contig=$(echo $line | cut -d, -f5 | sed 's/"//g')
if [[ $line = *'"p"'* ]]; then
echo $contig,"plasmid","rfplasmid" >> ../results/${output_file}
else
echo $contig,"chromosome","rfplasmid" >> ../results/${output_file}
fi
done
}

while getopts :o: flag; do
	case $flag in
		o) output_file=$OPTARG;;
	esac
done

gather_mlplasmids
gather_plascope
gather_platon
gather_rfplasmid
