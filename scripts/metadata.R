## USAGE: Merge two metadata tables into one.
#Input: Two xlsx files containing different metadata
#Output: One csv file containing all metadata

#libraries
library(readxl)
library(dplyr)

#Set working directory to the directory containing metadata files
setwd("C:/Users/lies/Documents/Master/Major Research Project/Data/metadata")

#import files
file1 <- read_excel("./all_rgnosis_strains_metadata_20200223.xlsx")
file2 <- read_excel("./RGNOSIS_WGS_DATA_20210203.xlsx", sheet = "results")
file1 <- rename(file1, All_results = all_results)

#remove empty lines (!! This removes all lines without an All_results ID, even if they contain other info!)
file2 <- file2 %>% filter(All_results!="NA")

#merge datasets
result <- full_join(file1,file2,by="All_results")
result <- result %>% relocate(All_results)

#What is present in the result file but not in file1?
setdiff(merged$All_results,file1$All_results)

#export file
write.csv(result,"./merged_metadata.csv",row.names = FALSE)
