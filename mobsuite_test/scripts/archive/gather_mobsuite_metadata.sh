echo 'sra_accession,assembly_accession,length,classification' > mobsuite_metadata.csv
cd mob_predictions
sra_accessions=$(ls)
for sra_acc in ${sra_accessions}
do
assembly_acc=$(grep ${sra_acc} ../accessions_table.csv | cut -d , -f 1)
cd ${sra_acc} 
replicons=$(ls *.fasta)
for replicon in ${replicons}
do
length=$(cat ${replicon} | grep -v ">" | tr -d '\r\n' | wc -m)
classification=$(ls ${replicon} | cut -d _ -f 1 | cut -d . -f 1)
echo ${sra_acc},${assembly_acc},${length},${classification} >> ../../mobsuite_metadata.csv
done
cd ..
done
