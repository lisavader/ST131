## USAGE: Merge two metadata tables into one.
#Input: Two xlsx files containing different metadata
#Output: One csv file containing all metadata

#libraries
library(readxl)
library(magrittr)
library(dplyr)

#Set working directory to the directory containing metadata files
setwd("C:/Users/lies/Documents/Master/Major Research Project/Data/metadata")

#import files
rgnosis_metadata <- read_excel("./all_rgnosis_strains_metadata_20200223.xlsx") %>% rename(sample_ID = all_results)
WGS_metadata <- read_excel("./RGNOSIS_WGS_DATA_20210203.xlsx", sheet = "results") %>% rename(sample_ID = All_results)
WGS_metadata[105,1] = 43613 #correct faulty sample ID

#remove empty lines (!! This removes all lines without a sample ID, even if they contain other info!)
WGS_metadata <- WGS_metadata %>% filter(sample_ID!="NA")

#merge datasets and export file
result <- left_join(WGS_metadata,rgnosis_metadata,by="sample_ID")
write.csv(result,"./merged_metadata.csv",row.names = FALSE)
