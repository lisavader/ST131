#I created a conda environment based on the file ncbi_download_mmbioit.yml set up by Julian Paganini. 
#This environment contains all the tools I used.

cd ~/data/scripts/06_04_2021/
conda env create -f ncbi_download_mmbioit.yml
conda activate ncbi_download_mmbioit

#I searched for all E. coli hybrid assemblies on the https://www.ncbi.nlm.nih.gov/ Assembly database.
#I used the following search terms:
#(gridion[Sequencing Technology] OR pacbio[Sequencing Technology] OR pacific[Sequencing Technology] OR minion[Sequencing Technology] OR nanopore[Sequencing Technology] OR sequel[Sequencing Technology]) AND illumina[Sequencing Technology] AND ("Escherichia coli"[Organism] OR Escherichia coli[All Fields]) AND (latest[filter] AND "complete genome"[filter] AND all[filter] NOT anomalous[filter])
#And saved the accessions in a file called 2021_04_12_hybrid_ecoli_accessions.

#To download their sequences in fasta format:
cd ~/data/genome_download
accessions=$(cat 2021_04_12_hybrid_ecoli_accessions)

for strain in $accessions
do
esearch -db assembly -query ${strain} | elink -target nuccore | efetch -format fasta  > genomes/${strain}.fna
done

#Running mlst:
mlst genomes/* > mlst_output.tsv

#Some genomes were downloaded in duplicate, creating a double allelic output in the mlst table, eg. adk(53,53) instead of adk(53).
#Because strains containing multiple alleles are by default not assigned a ST, I used the following code to select all ST131 strains:
cat mlst_output.tsv | grep adk.53.*fumC.*40.*gyrB.47.*icd.13.*mdh.*36.*purA.28.*recA.*29.* | cut -f 1 | cut -c 9-23 > hybrid_ST131_accessions

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
