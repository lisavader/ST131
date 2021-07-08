#!/usr/bin/env Rscript

library(dplyr)

metadata <- read.csv("../results/longread_ST131_metadata.csv")
names(metadata) <- c("assembly_accession","biosample","bioproject","seq_technology")
sra_accessions <- read.csv("../results/accessions_table.csv")
names(sra_accessions) <- c("assembly_accession","sra_accession")

merged <- inner_join(metadata,sra_accessions,by="assembly_accession")
merged
