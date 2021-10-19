
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

#select metadata for general analysis
ST131_metadata_selected <- ST131_metadata %>% select(run_ID,treatment,SITE_N,tracti)
write.csv(ST131_metadata_selected,"selected_ST131_metadata.csv",row.names = FALSE)

#select metadata for microreact
ST131_metadata_microreact <- ST131_metadata %>% rename(id=run_ID,year=sample_yr,month=sample_mo,day=sample_day) %>% select(id,treatment,SITE_N,tracti,year,month,day)

#geocode with tmap
hospital_info <- data.frame(query=unique(ST131_metadata_microreact$SITE_N) %>% substring(.,4),hospital_ID=unique(ST131_metadata_microreact$SITE_N) %>% substring(.,0,2))
#For these locations I had to change the query, otherwise tmap couldn't find them:
hospital_info$query[9] <- "Gent"
hospital_info$query[10] <- "Golnik"
hospital_coordinates <- geocode_OSM(hospital_info$query)

#merge the coordinate info with the microreact metadata
hospital_coordinates <- merge(hospital_coordinates %>% select(query,lat,lon),hospital_info)
ST131_metadata_microreact %<>% mutate(hospital_ID=substring(SITE_N,0,2))
ST131_metadata_microreact %<>% full_join(hospital_coordinates,by="hospital_ID") 
ST131_metadata_microreact %<>% select(!query) %>% rename(latitude=lat,longitude=lon)

#add autocolour to headers
ST131_metadata_microreact %<>% rename_with(~paste0(.,"__autocolour"),c(SITE_N,tracti,treatment))
write.csv(ST131_metadata_microreact,"ST131_metadata_microreact.csv",row.names = FALSE)
