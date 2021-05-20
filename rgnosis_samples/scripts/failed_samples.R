library(readr)
library(dplyr)
library(magrittr)
setwd("T:/microbiologie/Sequencing/Bio-Informatica/Lisa_Vader/")
multiqc_mlst <- read_delim("./results/bactofidia_23032021/stats/MultiQC_report_data/multiqc_mlst.txt", "\t", escape_double = FALSE, trim_ws = TRUE)
multiqc_quast <- read_delim("./results/bactofidia_23032021/stats/MultiQC_report_data/multiqc_quast.txt", "\t", escape_double = FALSE, trim_ws = TRUE)
multiqc_mlst <- multiqc_mlst[,c(1:3)] #only keep species and MLST columns
multiqc_mlst %<>% mutate(Sample=gsub(".fna","",Sample))
merged <- full_join(multiqc_quast,multiqc_mlst,by="Sample")


WGS_metadata <- read_delim("./data/metadata/RGNOSIS_WGS_DATA_clean.csv", ";", trim_ws = TRUE)
failed_run <- na.omit(WGS_metadata$`failed run`)
failed_run %<>% strsplit("/") %>% unlist()
merged %<>% mutate(previously_failed=Sample %in% failed_run)
merged <- merged[c(1,23,24,25,16,2:15,17:22)] #rearrange columns
merged %<>% arrange(`Total length (>= 0 bp)`)

failed_samples <- filter(merged,`Total length (>= 0 bp)`<4400000 | `Total length (>= 0 bp)` >6100000) #filter abnormal lengths
write.csv(failed_samples,"./results/bactofidia_23032021/samples_abnormal_length.csv",row.names=FALSE)
write.csv(merged,"./results/bactofidia_23032021/sample_summaries.csv",row.names=FALSE)