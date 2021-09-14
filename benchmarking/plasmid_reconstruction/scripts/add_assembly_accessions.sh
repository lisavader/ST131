#set mode
while getopts :m: flag; do
        case $flag in
                m) mode=$OPTARG;;
        esac
done

#add assembly accessions to alignments statistics file
cd ../results/quast_statistics/${mode}

cat ${mode}_alignments_statistics.csv | while read line
do
sra_accession=$(echo $line | cut -d , -f 1)
assembly_accession=$(cat ../../../../../ST131_ncbi_download/results/accessions_table.csv | grep $sra_accession | cut -d , -f 1)
echo $assembly_accession,$line >> outfile.csv
done

cat outfile.csv > ${mode}_alignments_statistics.csv
rm outfile.csv
