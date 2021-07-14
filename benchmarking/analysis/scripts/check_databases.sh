
#get all replicons and all assembly accessions in testing dataset
all_replicons=$(cat ../../../ST131_ncbi_download/results/replicon_data.csv | cut -d, -f2)
all_assemblies=$(cat ../../../ST131_ncbi_download/results/accessions_table.csv | cut -d, -f1 | sed '1d')

#remove previous files (if existing)
rm ../results/replicons_in*

##PLATON
#find replicons
echo 'Processing platon database...'
for replicon in $all_replicons
do
grep $replicon ../../platon/data/db/refseq-plasmids.tsv | cut -f3 | sed 's/NZ_//' >> ../results/replicons_in_platon
done
#map replicons to assembly accessions
platon_replicons=$(cat ../results/replicons_in_platon)
for replicon in $platon_replicons
do
grep $replicon ../../../ST131_ncbi_download/results/replicon_data.csv | cut -d, -f1 >> outfile
done
#remove duplicates and save
cat outfile | sort -u > ../results/assemblies_in_platon
rm outfile

##RFPLASMID
echo 'Processing rfplasmid database...'
#download training set data
mkdir ../../rfplasmid/data
#wget -O ../../rfplasmid/data/ncbi_info_trainingset.tsv klif.uu.nl/download/plasmid_db/trainingsets2/ncbiftp
#check assemblies in training set
for assembly in $all_assemblies
do
grep $assembly ../../rfplasmid/data/ncbi_info_trainingset.tsv | cut -f1 >> outfile
done
#remove duplicates and save
cat outfile | sort -u > ../results/assemblies_in_rfplasmid
rm outfile

##PLASCOPE
echo 'Processing plascope database...'
#download database info
#wget -O ../../plascope/data/ncbi_info_database.pdf https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6202455/bin/mgen-4-211-s001.pdf
#pdftotext -layout -f 1 -l 104 ../../plascope/data/ncbi_info_database.pdf ../../plascope/data/ncbi_info_database.txt
#find replicons
for replicon in $all_replicons
do
grep $replicon ../../plascope/data/ncbi_info_database.txt | tr -s ' ' | cut -d ' ' -f3 | sed 's/NZ_//' >> ../results/replicons_in_plascope
done
#map replicons to assembly accessions
plascope_replicons=$(cat ../results/replicons_in_plascope)
for replicon in $plascope_replicons
do
grep $replicon ../../../ST131_ncbi_download/results/replicon_data.csv | cut -d, -f1 >> outfile
done
#remove duplicates and save
cat outfile | sort -u > ../results/assemblies_in_plascope
rm outfile

##MLPLASMIDS
echo 'Processing mlplasmids database...'
#download replicons in training set
#Mlplasmids only has this info available as an .xls file with multiple tabs, which is a pain to convert to some readable format.
#You can get the .xls file here: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6321875/bin/mgen-4-224-s002.xls and save the replicon IDs in the mlplasmids data folder.
#find replicons
for replicon in $all_replicons
do
grep $replicon ../../mlplasmids/data/training_data_replicons.csv | sed 's/NZ_//' >> ../results/replicons_in_mlplasmids
done
#map replicons to assembly accessions
mlplasmids_replicons=$(cat ../results/replicons_in_mlplasmids)
for replicon in $mlplasmids_replicons
do
grep $replicon ../../../ST131_ncbi_download/results/replicon_data.csv | cut -d, -f1 >> outfile
done
#remove duplicates and save
cat outfile | sort -u > ../results/assemblies_in_mlplasmids
rm outfile

##MOBSUITE
echo 'Processing mobsuite database...'
#download replicons in training set
#Mobsuite only has this info available as an .xls file.
#You can get the .xls file here: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6159552/bin/mgen-5-206-s003.xlsx and save the replicon IDs in the mobsuite data folder.
#find replicons
for replicon in $all_replicons
do
query=$(echo $replicon | cut -d. -f1)
grep $query ../../mobsuite/data/replicons_in_database.csv | sed 's/NZ_//' >> ../results/replicons_in_mobsuite
done
#map replicons to assembly accessions
mlplasmids_replicons=$(cat ../results/replicons_in_mobsuite)
for replicon in $mlplasmids_replicons
do
grep $replicon ../../../ST131_ncbi_download/results/replicon_data.csv | cut -d, -f1 >> outfile
done
#remove duplicates and save
cat outfile | sort -u > ../results/assemblies_in_mobsuite
rm outfile

#total assemblies occurring in one of the databases
cd ../results
cat assemblies_in* | sort -u > assemblies_to_remove

#convert to replicons
assemblies=$(cat assemblies_to_remove)
for assembly in $assemblies
do
grep $assembly ../../../ST131_ncbi_download/results/replicon_data.csv | cut -d, -f2 >> replicons_to_remove
done
