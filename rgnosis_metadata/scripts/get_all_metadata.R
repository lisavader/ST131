
packages=c("readr","readxl","magrittr","dplyr","stringr","xtable","tidyr","ggplot2","tmaptools")
for (package in packages){
  if (!require(package, character.only = TRUE)) install.packages(package)
  require(package, character.only = TRUE)
}

setwd("T:/microbiologie/Sequencing/Bio-Informatica/Lisa_Vader/")

#Import files
rgnosis_metadata <- read_excel("data/metadata/all_rgnosis_strains_metadata_20200223.xlsx")
Julians_metadata <- read_delim("./data/metadata/full_meta_data.csv", ',', trim_ws = TRUE)
WGS_metadata <- read_delim("./data/metadata/RGNOSIS_WGS_DATA_clean.csv", ";", trim_ws = TRUE)
ST131_assembly_summaries <- read_delim("./results/bactofidia/bactofidia_23032021/sample_summaries_ST131.csv", ";", trim_ws = TRUE)
Ecoli_accessions <- read_delim("all_ecoli_rgnosis.txt","/n",col_names = FALSE)

#Rename columns
rgnosis_metadata %<>% rename(sample_ID = all_results)
Julians_metadata %<>% rename(sample_ID = all_results, run_ID = Sample)
WGS_metadata %<>% rename(sample_ID = All_results, run_ID = UNIQUE_ID)
ST131_assembly_summaries %<>% rename(run_ID = Sample)
colnames(Ecoli_accessions) <- "run_ID"

#change run_ID delimiter in Julians_metadata and remove .fna extension in WGS metadata
Julians_metadata %<>% mutate(run_ID=str_replace_all(run_ID,'_','-')) 
WGS_metadata %<>% mutate(run_ID=str_replace(run_ID,'.fna',''))

#Gather all sample and run IDs in a dataframe
WGS_IDs <- WGS_metadata %>% select(sample_ID,run_ID)
Julians_IDs <- Julians_metadata %>% select(sample_ID,run_ID)
all_IDs <- bind_rows(WGS_IDs,Julians_IDs)

##ST131
#Get ST131 metadata
ST131_IDs <- inner_join(all_IDs,ST131_assembly_summaries,by="run_ID") %>% select(sample_ID,run_ID) %>% filter(sample_ID!='NA')
ST131_metadata <- inner_join(ST131_IDs,rgnosis_metadata) %>% select(sample_ID,run_ID,subject,SITE_N,stud_per,samp_per,INCL,tracti,ICU_LOS,sample_date,adm_date_icu,everything())

#Find samples for which study_per and samp_per do not match
nonmatching_periods <- ST131_metadata %>% filter(stud_per!=samp_per) %>% select(sample_ID,stud_per,samp_per,SITE_N)
write.table(nonmatching_periods,"nonmatching_periods.txt",sep = "\t",row.names = FALSE)

#Add treatment column
ST131_metadata %<>% mutate(treatment=stud_per)%>% select(1:4,treatment,everything())
#make baseline if interruption or before study start
baseline_treatments <- c('baseline period','INTERRUPTION','before study start')
ST131_metadata %<>% mutate(treatment = ifelse(stud_per %in% baseline_treatments, 'baseline', treatment))
#make baseline if INCL = no
ST131_metadata %<>% mutate(treatment = ifelse(INCL == 'no', 'baseline', treatment))

#Make a nice table
hospital_distribution <- table(ST131_metadata$SITE_N,ST131_metadata$treatment)
write.table(hospital_distribution,"hospital_distribution.txt",sep = "\t")

#summarise metadata
summary <- ST131_metadata %>% select(SITE_N,stud_per,INCL)

#Export metadata file
write.csv(ST131_metadata,"data/metadata/ST131_metadata_20210521.csv",row.names = FALSE)

##Plotting
theme_set(theme_bw())

#Days at ICU
ggplot(ST131_metadata,aes(x=ICU_LOS, fill=INCL)) +
  geom_histogram(binwidth = 5,breaks = seq(0,85,by=5),colour='black')+
  scale_x_continuous(breaks= seq(0,85,by=10))+
  scale_y_continuous(breaks= seq(0,20,by=5),minor_breaks = seq(0,20,by=1))+
  labs

#Days at ICU when sampled
ST131_metadata %<>% mutate(LOS_sampled=as.Date(sample_date)-as.Date(adm_date_icu))
ST131_metadata %<>% select(1:12,LOS_sampled,everything())

#exclude weird sample in row 76
ggplot(ST131_metadata[-76,],aes(x=LOS_sampled, fill=INCL)) +
  geom_histogram(binwidth = 1,colour="black")+
  scale_x_continuous(breaks= seq(0,60,by=10))+
  scale_y_continuous(breaks= seq(0,20,by=5),minor_breaks = seq(0,20,by=1))

#fun plot of both
ggplot(ST131_metadata[-76,],aes(x=ICU_LOS,y=LOS_sampled))+
  geom_point()+
  geom_abline()
#what's up with 63338?

##E.coli
#Get E.coli metadata
Ecoli_IDs <- inner_join(all_IDs,Ecoli_accessions,by="run_ID")
Ecoli_metadata <- inner_join(Ecoli_IDs,rgnosis_metadata) %>% select(sample_ID,run_ID,subject,SITE_N,stud_per,samp_per,INCL,tracti,ICU_LOS,sample_date,adm_date_icu,everything())

#Find samples for which study_per and samp_per do not match
nonmatching_periods <- Ecoli_metadata %>% filter(stud_per!=samp_per) %>% select(sample_ID,stud_per,samp_per,SITE_N)
write.table(nonmatching_periods,"nonmatching_periods.txt",sep = "\t",row.names = FALSE)

#Add treatment column
Ecoli_metadata %<>% mutate(treatment=samp_per)%>% select(1:4,treatment,everything())
#make baseline if before study start
baseline_treatments <- c('baseline period','before study start')
Ecoli_metadata %<>% mutate(treatment = ifelse(samp_per %in% baseline_treatments, 'baseline', treatment))
#make baseline if INCL = no
Ecoli_metadata %<>% mutate(treatment = ifelse(INCL == 'no', 'baseline', treatment))

#Make a nice table
hospital_distribution <- table(Ecoli_metadata$SITE_N,Ecoli_metadata$treatment)
write.table(hospital_distribution,"hospital_distribution.txt",sep = "\t")

#select metadata for analysis
Ecoli_metadata_selected <- Ecoli_metadata %>% select(run_ID,treatment,SITE_N,tracti,INCL,samp_per,stud_per,ICU_LOS,Culture_type,sample_yr,sample_mo,sample_day,age_adm_icu,acute_ill,AB,DIED_icu,ESBL,IPM:OFX)
Ecoli_metadata_selected %<>% rename(id=run_ID,year=sample_yr,month=sample_mo,day=sample_day)
write.csv(Ecoli_metadata_selected,"data/metadata/selected_metadata.csv",row.names = FALSE)

#geocode with tmap
hospital_info <- data.frame(query=unique(Ecoli_metadata_selected$SITE_N) %>% substring(.,4),hospital_ID=unique(Ecoli_metadata_selected$SITE_N) %>% substring(.,0,2))
#For these locations I had to change the query, otherwise tmap couldn't find them:
hospital_info %<>% mutate(query=ifelse(query=="Hospital Clinic of Barcelona, Barcelona, SPAIN","Barcelona",query))
hospital_info %<>% mutate(query=ifelse(query=="Academisch Ziekenhuis Sint Lucas, Gent, BELGIUM","Gent",query))
hospital_info %<>% mutate(query=ifelse(query=="University clinic of respiratory and allergic diseases, G","Golnik",query))
hospital_info %<>% mutate(query=ifelse(query=="Clinique St Pierre Ottiginies, BELGIUM","Ottignies",query))
hospital_coordinates <- geocode_OSM(hospital_info$query)

#merge the coordinate info with the microreact metadata
hospital_coordinates <- merge(hospital_coordinates %>% select(query,lat,lon),hospital_info)
Ecoli_metadata_selected %<>% mutate(hospital_ID=substring(SITE_N,0,2))
Ecoli_metadata_selected %<>% full_join(hospital_coordinates,by="hospital_ID") 
Ecoli_metadata_selected %<>% select(!query) %>% rename(latitude=lat,longitude=lon)

#add autocolour to headers
Ecoli_metadata_selected %<>% rename_with(~paste0(.,"__autocolour"),c(SITE_N,tracti,treatment))
write.csv(Ecoli_metadata_selected,"Ecoli_metadata_selected.csv",row.names = FALSE)
