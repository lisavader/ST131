sra_accessions=$(cat ~/data/genome_download/longread_ST131_sra_accessions)

echo "Assembly Accession,SRA Accession" > accessions_table.csv

for sra_accession in $sra_accessions
do
assembly_accession=$(esearch -db sra -query ${sra_accession} | elink -target biosample | elink -target assembly | esummary | xmllint --xpath "string(//Genbank)" -)
echo ${assembly_accession},${sra_accession} >> accessions_table.csv
done

