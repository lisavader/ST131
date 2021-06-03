cd ../results/quast_output

cat mob_alignments_statistics.csv | while read line
do
sra_accession=$(echo $line | cut -d , -f 1)
assembly_accession=$(cat ../../../../ST131_ncbi_download/results/accessions_table.csv | grep $sra_accession | cut -d , -f 1)
echo $assembly_accession,$line >> outfile.csv
done

cat outfile.csv > mob_alignments_statistics.csv
rm outfile.csv
