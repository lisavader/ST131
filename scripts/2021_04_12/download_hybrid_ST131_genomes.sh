#I created a conda environment based on the file ncbi_download_mmbioit.yml set up by Julian Paganini. 
#This environment contains all the tools I used.

cd ~/data/scripts/06_04_2021/
conda env create -f ncbi_download_mmbioit.yml
conda activate ncbi_download_mmbioit

#I searched for all E. coli long read assemblies in the https://www.ncbi.nlm.nih.gov/ Assembly database.
#I used the following search terms:
#(hybrid[Sequencing Technology] OR gridion[Sequencing Technology] OR pacbio[Sequencing Technology] OR pacific[Sequencing Technology] OR minion[Sequencing Technology] OR nanopore[Sequencing Technology] OR sequel[Sequencing Technology]) AND ("Escherichia coli"[Organism] OR Escherichia coli[All Fields]) AND (latest[filter] AND "complete genome"[filter] AND all[filter] NOT anomalous[filter])
#And saved the accessions (send to file: ID Table) in a file called 2021_04_15_longread_ecoli_list.

#To get their accessions and ftp paths:
cat 2021_04_15_longread_ecoli_list.txt | cut -f 1 | sed '1d' | sort > 2021_04_15_longread_ecoli_accessions
for accession in $accessions
do
esearch -db assembly -query ${accession} | esummary | xmllint --xpath "string(//FtpPath[@type='GenBank'])" - >> 2021_04_15_longread_ecoli_ftppaths
done

#Downloading the sequences in fasta format:
urls=$(cat 2021_04_15_longread_ecoli_ftppaths)
cd ~/data/genome_download/genomes

for url in $urls
do
name=$(cut -d / -f 10 <<<${url})
wget ${url}/${name}_genomic.fna.gz
done

#Running mlst:
mlst genomes/* > mlst_output.tsv

#I selected accessions belonging to ST131 as follows. I manually added one strain which for one of the alleles has a novel full length allele match similar to the 131 allele.
awk '$3 == 131' mlst_output.tsv | cut -f1 | sed 's/.*\///; s/_A.*//' > longread_ST131_accessions
echo "GCA_010724935.1" >> longread_ST131_accessions

#Downloading the assembly reports:
mkdir assembly_reports
grep -F -f longread_ST131_accessions 2021_04_15_longread_ecoli_ftppaths > longread_ST131_ftppaths
urls=$(cat longread_ST131_ftppaths)
for url in $urls
do 
wget ${url}/*assembly_report.txt -P assembly_reports/
done

#Creating metadata table:
echo 'Genbank assembly accession,BioSample,BioProject,Sequencing technology' > longread_ST131_metadata.csv

for report in assembly_reports/*assembly_report.txt
do
accession=$(grep 'GenBank assembly accession' ${report} | cut -d : -f 2 | xargs | dos2unix)
biosample=$(grep 'BioSample' ${report} | cut -d : -f 2 | xargs | dos2unix)
bioproject=$(grep 'BioProject' ${report} | cut -d : -f 2 | xargs | dos2unix)
seq_tech=$(grep 'Sequencing technology' ${report} | cut -d : -f 2 | xargs | dos2unix)
echo ${accession},${biosample},${bioproject},${seq_tech} >> longread_ST131_metadata.csv
done

#To find which biosamples have short reads uploaded in the sra database, and download the short reads: 
biosamples=$(cat longread_ST131_metadata.csv | sed '1d' | cut -d , -f 2)
for biosample in $biosamples
do 
esearch -db biosample -query "${biosample}" | elink -target sra | efetch -format runinfo  | grep 'Illumina\|ILLUMINA' | cut -f 1 -d , >> longread_ST131_sra_accessions
done

mkdir sra_files
sra_accessions=$(cat longread_ST131_sra_accessions)

for accession in $sra_accessions
do
fasterq-dump --split-files ${accession} -O sra_files
done
