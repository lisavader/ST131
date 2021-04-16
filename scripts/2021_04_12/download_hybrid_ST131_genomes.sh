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

#To get the biosamples that belong to the assembly accessions:
accessions=$(cat hybrid_ST131_accessions)
for accession in $accessions
do 
esearch -db assembly -query ${accession} | esummary | grep BioSampleAccn | cut -c 17-28 >> hybrid_ST131_biosamples
done

#To find which biosamples have short reads uploaded in the sra database, and save their sra accession: 
biosamples=$(cat hybrid_ST131_biosamples)
for biosample in $biosamples
do 
esearch -db biosample -query "${biosample}" | elink -target sra | efetch -format runinfo  | grep 'Illumina\|ILLUMINA' | cut -f 1 -d , >> hybrid_ST131_sra_accessions
done
