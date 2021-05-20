
require(readr)
require(readxl)
require(magrittr)
require(dplyr)
require(stringr)

setwd("T:/microbiologie/Sequencing/Bio-Informatica/Lisa_Vader/")

#Import files
rgnosis_metadata <- read_excel("data/metadata/all_rgnosis_strains_metadata_20200223.xlsx")
Julians_metadata <- read_delim("./data/metadata/full_meta_data.csv", ',', trim_ws = TRUE)
WGS_metadata <- read_delim("./data/metadata/RGNOSIS_WGS_DATA_clean.csv", ";", trim_ws = TRUE)
ST131_assembly_summaries <- read_delim("./results/bactofidia/bactofidia_23032021/sample_summaries_ST131.csv", ";", trim_ws = TRUE)

#Rename columns
rgnosis_metadata %<>% rename(sample_ID = all_results)
Julians_metadata %<>% rename(sample_ID = all_results, run_ID = Sample)
WGS_metadata %<>% rename(sample_ID = All_results, run_ID = UNIQUE_ID)
ST131_assembly_summaries %<>% rename(run_ID = Sample)

#change run_ID delimiter in Julians_metadata and remove .fna extension in WGS metadata
Julians_metadata %<>% mutate(run_ID=str_replace_all(run_ID,'_','-')) 
WGS_metadata %<>% mutate(run_ID=str_replace(run_ID,'.fna',''))

#Gather all sample and run IDs in a dataframe
WGS_IDs <- WGS_metadata %>% select(sample_ID,run_ID)
Julians_IDs <- Julians_metadata %>% select(sample_ID,run_ID)
all_IDs <- bind_rows(WGS_IDs,Julians_IDs)

#Get ST131 metadata
ST131_IDs <- inner_join(all_IDs,ST131_assembly_summaries,by="run_ID") %>% select(sample_ID,run_ID) %>% filter(sample_ID!='NA')
ST131_metadata <- inner_join(ST131_IDs,rgnosis_metadata) %>% select(sample_ID,run_ID,subject,SITE_N,samp_per,tracti,everything())

#Make a nice table
table(ST131_metadata$SITE_N,ST131_metadata$samp_per)
