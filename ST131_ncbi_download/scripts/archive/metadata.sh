echo 'Genbank assembly accession,BioSample,BioProject,Sequencing technology' > longread_ST131_metadata.csv

for report in assembly_reports/*assembly_report.txt
do
accession=$(grep 'GenBank assembly accession' ${report} | cut -d : -f 2 | xargs | dos2unix)
biosample=$(grep 'BioSample' ${report} | cut -d : -f 2 | xargs | dos2unix)
bioproject=$(grep 'BioProject' ${report} | cut -d : -f 2 | xargs | dos2unix)
seq_tech=$(grep 'Sequencing technology' ${report} | cut -d : -f 2 | xargs | dos2unix)
echo ${accession},${biosample},${bioproject},${seq_tech} >> longread_ST131_metadata.csv
done
