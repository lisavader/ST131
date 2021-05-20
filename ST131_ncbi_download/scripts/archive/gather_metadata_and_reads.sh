#!/bin/bash

#Hi Lisa,

# Find here the code for gathering the metadata for the isolates that you will get from ncbi-genome-download. You should run this tool using the -m flag, which will download also a metadata file that will also be useful. (Mostly for getting accession codes, biosamples codes, etc)

#I've attached a .yml file that will allow you to create a conda environment that contains all the tools needed (this is optional, more details later on the code)

#I've also attached an R script as an example

#important: Downloading all this data will occupy a lot of hard-drive storage space. Therefore, I recommend doing this directly on the HPC. Maybe using sbatch will be better, because this might take a long time.

#Best of success! We'll keep in touch.

#Cheers


###--------------------------1. Gather extra metadata using Entrez utilities--------------------------------------------

#1.0 Create and activate environment that contains the tools needed for downloading the files (not strictly necessary, you could download the tools yourself and create your own environment)

source ${conda}/etc/profile.d/conda.sh   #this has to point to your conda installation. Therefore you should replace ${conda} with the location from your miniconda directory ... ie: ~/data/miniconda3

conda env create -f ../envs/ncbi_download_mmbioit.yml #I'm attaching this file as well.

conda activate ncbi_download_mmbioit

#1.1 get the assembly codes to gather the metadata (The assembly codes were obtained from the 2020_08_25_ecoli_list.csv file, which was generated thru the ncbi-genome-download tool, using the -m flag)

cat 2020_08_25_ecoli_list.csv | cut -f 1 | sed '1d' > 2020_08_25_ncbi_accessions.csv

#1.2 start gathering the data. For this we will use the entrez utility application. This application can be obtained from conda https://anaconda.org/bioconda/entrez-direct. Or it can be installed from the environment file ncbi_download_mmbioit.yml

accessions=$(cat 2020_08_25_ncbi_accessions.csv)

echo 'gathering metadata, probably youll get enough time to make yourself a tea... or two...'

#1.2.1 create directory to store the output

mkdir accessions

#1.2.2 Run a loop thru every accession code to download the gb file, and gather the metadata from it
for strains in $accessions:
do
esearch -db assembly -query ${strains} | elink -target nuccore | efetch -format gb  > accessions/${strains}.txt
done

#1.3 Extract the metadata from the files downloaded in 1.2
cd accessions

files=$(ls *txt | sed 's/.txt//g')

for strain in ${files[@]}
do
  		country=$(grep '/country' ${strain}.txt | cut -f 1 -d : | sort -u | sed -z "s/\n//g" | cut -f 2 -d = | sed -z 's/"//g' | sed "s/,/;/g" )
        source=$(grep '/isolation_source' ${strain}.txt | cut -f 1 -d : | sort -u | sed -z "s/\n//g" | cut -f 2 -d = | sed -z 's/"//g' | sed "s/,/;/g" )
        host=$(grep '/host' ${strain}.txt | cut -f 1 -d : | sort -u | sed -z "s/\n//g" | cut -f 2 -d = | sed -z 's/"//g' | sed "s/,/;/g" )
        seq_tech=$(grep 'Sequencing Technology' ${strain}.txt | sed 's/: /:/g' | cut -f 3 -d : | sort -u | sed "s/,/;/g" )
        echo ${strain},${seq_tech},${country},${host},${source} >> ../2020_08_25_eutils_metadata.csv
done


###------2. I would recommend to create an R code to:----------------#
#1. fuse the metadata obtained from the ncbi-genome-download (2020_08_25_ecoli_list.csv in my case) with the file that you've just created
#2. filter the strains that you are interested in (ST131 strains that were sequened by a Hybrid method)
#3. Also, keep the "biosample" and "bioprojects" columns in this file, since we will use them in step #3.
#4. If your are going to run R in the HPC explore the Rscript command (I'm attaching an example of the file that I used)

###-----3. Now we will check which of these strains actually have the short reads uploaded to the SRA database------#

#3.1- Get the list of the biosamples Id to check if we have the reads 

biosamples=$(cat ../../2020_08_25_ecoli_metadata/results/all_metadata.csv | cut -f 3 -d , | sed 's/"//g' | grep -v biosample)

#all_metadata.csv is the file obtained from step #2. (you could obviously choose another name, and your folder structure will also be different)

#3.2. Now, we will create a list of the SRA accession names. For this we will also use the Entrez utils applcation

for biosample in $biosamples
do
sra_accession=$(esearch -db biosample -query "${biosample}" | elink -target sra | efetch -format runinfo  | grep 'Illumina\|ILLUMINA' | cut -f 1 -d ,)
echo ${biosample},${sra_accession} >> ../results/sra_accessions_list_all.csv
done

###------4. Now we will get the reads

#1. Get a list of sra_ids 
sra_accessions=$(cat ../results/benchmark_sra_list.csv) 


#2. Make a directory for holding the results
mkdir ../data/sra_files


#3. Make a loop to download the fastq files (the fasterq-dump app is part of the sra-toolkit, which can be downloaded from Anaconda https://anaconda.org/bioconda/sra-tools or which can be directly obtained by creating the environment from the file ncbi_download_mmbioit.yml)
for reads in $sra_accessions
do
fasterq-dump --split-files ${reads} -O ../data/sra_files   
done










