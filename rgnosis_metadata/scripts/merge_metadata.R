## USAGE: Merge two metadata tables into one.
#Input: Two files containing different metadata
#Output: One csv file containing all metadata

#libraries
library(readxl)
library(readr)
library(magrittr)
library(dplyr)

#Set working directory to the directory containing metadata files
setwd("T:/microbiologie/Sequencing/Bio-Informatica/Lisa_Vader/data/metadata")

#import files
rgnosis_metadata <- read_excel("./all_rgnosis_strains_metadata_20200223.xlsx") %>% rename(sample_ID = all_results)
WGS_metadata <- read_delim("./RGNOSIS_WGS_DATA_clean.csv", ";") %>% rename(sample_ID = All_results)

#merge datasets and export file
result <- left_join(WGS_metadata,rgnosis_metadata,by="sample_ID")
write.csv(result,"./merged_metadata_3rdrun.csv",row.names = FALSE)
