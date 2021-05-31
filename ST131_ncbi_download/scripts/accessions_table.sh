#activate conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate ncbi_download_mmbioit

sra_accessions=$(cat ../results/longread_ST131_sra_accessions)

#build table with column names
echo "Assembly Accession,SRA Accession" > accessions_table.csv

#for each sra accession, find the corresponding assembly accession using entrez utilities and append to table
for sra_accession in $sra_accessions
do
assembly_accession=$(esearch -db sra -query ${sra_accession} | elink -target biosample | elink -target assembly | esummary | xmllint --xpath "string(//Genbank)" -)
echo ${assembly_accession},${sra_accession} >> accessions_table.csv
done

