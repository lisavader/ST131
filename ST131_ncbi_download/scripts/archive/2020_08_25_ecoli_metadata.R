library(tidyr)
library(dplyr)
library(readxl)

####------- set the wroking directory to file location------------------------------------------#
getScriptPath <- function(){
  cmd.args <- commandArgs()
  m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)
  script.dir <- dirname(regmatches(cmd.args, m))
  if(length(script.dir) == 0) stop("can't determine script dir: please call the script with Rscript")
  if(length(script.dir) > 1) stop("can't determine script dir: more than one '--file' argument detected")
  return(script.dir)
}

# Setting the script path would then be:
setwd(getScriptPath())


#---------------1. Load metadata--------------------------------------------------
ncbi_download<-read.csv('../data/2020_08_25_ecoli_list.csv', header=TRUE, sep='\t')

genomes_meta<-read.csv('../data/2020_08_25_eutils_metadata.csv', header=FALSE, sep=',',stringsAsFactors = FALSE)
names(genomes_meta)<-c("gbrs_paired_asm","seq_tech","country","host","isolation_source")

#-------------------2. #filter strains that have been sequenced by long read------------------------------
genomes_meta_filtered<-genomes_meta[grep((pattern="GridION|gridION|PacBio|Pacific|MinION|MiniION|Nanopore|pacBio|Hybrid|Sequel"),genomes_meta$seq_tech),]

print('replacing empty values')
#replace empty values
genomes_meta_filtered[genomes_meta_filtered=='']<-"no_data"

print('joining data')
#join with ncbi_data
all_data<-inner_join(ncbi_download,genomes_meta_filtered,by=c("assembly_accession"="gbrs_paired_asm"))

print('filtering columns')
#filter relevant columns
important_metadata_raw<-all_data[,c("assembly_accession","bioproject","biosample","organism_name","infraspecific_name","asm_name","gbrs_paired_asm","seq_rel_date","seq_tech","country","host","isolation_source","ftp_path")]

print('getting assembly codes')
#get only the accession codes, this will be utilized to filter the data.
assembly_codes<-as.data.frame(important_metadata_raw[,c("assembly_accession")])
names(assembly_codes)<-'isolates'
dim(assembly_codes) #1395 strains

#--------------------3. Filter strains that are really e. coli-----------------------------------------

print('import clermon classifications')
#import Clermon-typing data
clermon_classification<-read.csv('../data/clermon_output/clermon_output_phylogroups.txt', header=FALSE, sep='\t')
names(clermon_classification)<-c("isolate","genes","presence_absence","variant","phlyogroup","mash_file")
dim(clermon_classification)
head(clermon_classification)

print('removing strains from clades')
#remove the strains from clades
clermon_classification_filtered<-clermon_classification[-grep("clade",clermon_classification$phlyogroup),] 
clermon_classification_filtered<-clermon_classification_filtered[-grep("Unknown",clermon_classification_filtered$phlyogroup),]
print('clermon_classification_filtered')
dim(clermon_classification_filtered)
head(clermon_classification_filtered)

print('remove poppunk strains')
#Remove two strains that were found to be separated from E. coli according to PopPUNK analysis
#GCA_013894235.1_ASM1389423v1_genomic.fna
#GCA_013817505.1_ASM1381750v1_genomic.fna
clermon_classification_filtered<-clermon_classification_filtered[-grep("GCA_013894235.1_ASM1389423v1_genomic.fna",clermon_classification_filtered$isolate),]
clermon_classification_filtered<-clermon_classification_filtered[-grep("GCA_013817505.1_ASM1381750v1_genomic.fna",clermon_classification_filtered$isolate),]
dim(clermon_classification_filtered) #1381 E. coli for sure, that have been sequenced by Long read or Hybrid

print('get the names that will be used for the analysis')
#drop unimportant information and get the names of the strains that will be used for the analysis
ecoli_strain_analysis_raw<-clermon_classification_filtered[,c(1,5)]
head(ecoli_strain_analysis_raw)
ecoli_strain_analysis<-separate(ecoli_strain_analysis_raw,'isolate',into=c('strain','rest'),sep='.f')
ecoli_strain_analysis<-ecoli_strain_analysis[,c(1)]
write.table(ecoli_strain_analysis,'../results/final_strain_list.csv',row.names=FALSE, col.names =   FALSE)

#--------------------4. Get important metadata-----------------------------------------------------

#get the real important metadata for the rest of the analysis
#separate the name of the strains in ecoli_strain_analysis_raw to be able to merge it with the metadata
ecoli_new_names<-separate(ecoli_strain_analysis_raw,'isolate',into=c('prefix','strain','code','the_rest'), sep='_')
ecoli_new_names<-ecoli_new_names %>% unite("isolate",c(prefix,strain),sep="_")
#drop columns that are not important
ecoli_new_names<-ecoli_new_names[,-c(2,3)]
head(ecoli_new_names)

#join with metadata
important_metadata<-inner_join(important_metadata_raw,ecoli_new_names,by=c('assembly_accession'='isolate'))
#drop last column
head(important_metadata)
dim(important_metadata)




#-------------------- 5 . assign a continent to each strain-----------------------------------------

#Check the different countries present in our data-set
country_count<-important_metadata %>% group_by(country) %>% summarise(count_country=n())
important_metadata_country<-inner_join(important_metadata,country_count, by='country')

#Create a new column for assigning the continent.
important_metadata_country$continent<-NA

important_metadata_country$continent[grep(pattern="Argentina|Brazil|Chile|Colombia|Cuba|Ecuador|Mexico|Paraguay",important_metadata_country$country)]<-'South-Central_America'

important_metadata_country$continent[grep(pattern="USA|Canada",important_metadata_country$country)]<-'North-America'

important_metadata_country$continent[grep(pattern="Austria|Belgium|Czech Republic|Denmark|France|Germany|Italy|Netherlands|Norway|Portugal|Slovakia|Sweden|Switzerland|United Kingdom|Greece",important_metadata_country$country)]<-'Europe'

important_metadata_country$continent[grep(pattern="Egypt|Gambia|Mali|Tanzania|Mozambique",important_metadata_country$country)]<-'Africa'

important_metadata_country$continent[grep(pattern="China|Bangladesh|Cambodia|Georgia|Hong Kong|India|Israel|Japan|Jordan|Korea|Lebanon|Malaysia|Pakistan|Myanmar|Qatar|Saudi Arabia|Singapore|South Korea|Taiwan|Thailand|Turkey|United Arab Emirates|Viet Nam|Iran|Sri Lanka",important_metadata_country$country)]<-'Asia'

important_metadata_country$continent[grep(pattern="Australia|New Zealand",important_metadata_country$country)]<-'Oceania'

important_metadata_country$continent[grep("no_data",important_metadata_country$country)]<-'no_data'

continent_count<-important_metadata_country %>% group_by(continent) %>% summarise(count_continent=n())

important_metadata_continet<-inner_join(important_metadata_country,continent_count,by='continent')

####---------------------------- 6. Analyze metadata by host --------------------------------------------------

#take a look at the information we have from the isolation source.
source_count<-important_metadata %>% group_by(isolation_source) %>% summarise(count_source=n())

#duplicate the imporat metadata dataframe
important_metadata_host<-important_metadata

# Add a new column called new host
important_metadata_host$new_host<-important_metadata_host$host

#summarize each category

important_metadata_host$new_host[grep(pattern="Yak|duck|pheasant|Fjerkrae|cockatoo|Bird|mutus|chlorocebus|crow|Corvus|panda|Larus|Marmota|Odocoileus virginianus|Papio papio|scrofa|camel|wild|bird|Chlorocebus|Deer|Chroicocephalus|Panda|fowl|Paguma|boar ",important_metadata_host$isolation_source)]<-'wild_animal'

important_metadata_host$new_host[grep(pattern="Yak|duck|pheasant|Fjerkrae|cockatoo|Bird|mutus|chlorocebus|crow|Corvus|panda|Larus|Marmota|Odocoileus virginianus|Papio papio|scrofa|camel|wild|bird|Chlorocebus|Deer|Chroicocephalus|Panda|fowl|Paguma|boar",important_metadata_host$host)]<-'wild_animal'

important_metadata_host$new_host[grep(pattern="mouse|Mouse|rat|Rat",important_metadata_host$isolation_source)]<-'Rat-Mouse'

important_metadata_host$new_host[grep(pattern="mouse|Mouse|rat|Rat",important_metadata_host$host)]<-'Rat-Mouse'

important_metadata_host$new_host[grep(pattern="dog|cat|Dog|Cat|canine|Canis",important_metadata_host$isolation_source)]<-'Household_animal'

important_metadata_host$new_host[grep(pattern="dog|cat|Dog|Cat|canine|Canis",important_metadata_host$host)]<-'Household_animal'

important_metadata_host$new_host[grep(pattern="water|Water|Sewage|River|river|creek|Creek|air|Air|soil|Coffea|Elaeis",important_metadata_host$isolation_source)]<-'Environmental'

important_metadata_host$new_host[grep(pattern="water|Water|Sewage|River|river|creek|Creek|air|Air|soil|Coffea|Elaeis",important_metadata_host$host)]<-'Environmental'

important_metadata_host$new_host[grep(pattern="mutton|milk|Milk|cheese|beef|meat|Meat|chops|Chops|lettuce|turkey|Turkey|lamb|cucumber|carcass|Legs|Bulgogi|Broiler|steak|Apple|alfalfa",important_metadata_host$isolation_source)]<-'Food'

important_metadata_host$new_host[grep(pattern="mutton|milk|Milk|cheese|beef|meat|Meat|chops|Chops|lettuce|turkey|Turkey|lamb|cucumber|carcass|Legs|Bulgogi|Broiler|steak|Apple|alfalfa",important_metadata_host$host)]<-'Food'

important_metadata_host$new_host[grep(pattern="sapiens|Sapiens|human|Human|patient|Patient|Homo",important_metadata_host$isolation_source)]<-'Homo sapiens'

important_metadata_host$new_host[grep(pattern="sapiens|Sapiens|human|Human|Patient|Homo",important_metadata_host$host)]<-'Homo sapiens'

#Assign categories based on $isoaltion_source column
important_metadata_host$new_host[grep(pattern="Swine|swine|pork|Pork|porcine|Pig|pig|goat|goose|chiken|Cattle|cattle|calf|Calf|bovine|Bovine|taurus|cow|Cow|Chicken|chicken|Gallus|sheep",important_metadata_host$isolation_source)]<-'Farm_animal'

#Assign categories based on information from $host column
important_metadata_host$new_host[grep(pattern="Swine|swine|pork|Pork|porcine|Pig|pig|goat|goose|chiken|Cattle|cattle|calf|Calf|bovine|Bovine|taurus|cow|Cow|Chicken|chicken|Gallus|sheep",important_metadata_host$host)]<-'Farm_animal'

#other category
#Assign categories based on $isoaltion_source column
important_metadata_host$new_host[grep(pattern="coli|Ash",important_metadata_host$isolation_source)]<-'Other'

#Assign categories based on information from $host column
important_metadata_host$new_host[grep(pattern="coli|Ash",important_metadata_host$host)]<-'Other'

#Create a data frame for summarizing the amount of each strain.

host_count<-important_metadata_host %>% group_by(new_host) %>% summarise(count_host=n())

#check the no-data sources

host_na_metadata<-filter(important_metadata_host,new_host=='no_data')

###------------------------7. Mix data from continet and host ------------------------------------------------

#filter importnat information from the important_metadata_continet data-frame and from important_metadata_host

filter_continet<-important_metadata_continet[,c("assembly_accession","continent","count_continent")]
filter_host<-important_metadata_host[,c("assembly_accession","new_host")]
#combine two data-frames

host_continent<-inner_join(filter_continet,filter_host,by="assembly_accession")

###------------------------8. Get ST information ------------------------------------------------

#import ST Information, obtained from running mlst/tseeman software
st_info <-read.csv('../data/mlst_all.tsv', sep='\t', header=FALSE)
names(st_info)<-(c(X1= "Strain", X2= "Species", X3= "ST",X4= "adk", X5= "fumC", X6= "gyrB",X7= "icd", X8= "mdh", X9= "purA",X10="recA" ))

###-------------------9. Add PopPUNK information and get all metadata together for microreact-----------------------
#upload data from poppunk clusters
poppunk_clusters<-read.csv('../data/poppunk_output/K6/K6_microreact_clusters.csv', header=TRUE, sep=',')
#filter information from st
st_filtered<-st_info[,c(1,3)]
#change the name of the strains to be able to merge it (remove _genomic.fna)
st_filtered$id<-st_filtered$Strain
st_filtered<-separate(st_filtered,'id',into=c('id','rest','third','fourth'),sep='_')
st_filtered$rest<-as.character(st_filtered$rest)
st_filtered$second<-as.character(st_filtered$rest)
st_filtered<-separate(st_filtered,'second',into=c('important','not_important'),extra = "drop", fill = "right")
#drop last three columns
st_filtered<-st_filtered[,-c(5,6,8)]
#reunite important columns for merging with popunk (id_pop) and for merging with rest of metadata (id_metadata)
st_filtered$id_metadata<-st_filtered$id
st_filtered<-st_filtered %>% unite("id_pop",c(id,important),sep="_")
st_filtered<-st_filtered %>% unite("id_metadata",c(id_metadata,rest),sep="_")
st_filtered$long_id<-st_filtered$Strain
st_filtered<-st_filtered %>% separate(long_id,into=c('prefix','middle','final','something'),sep='_')
st_filtered<-st_filtered %>% unite("long_id",c(prefix,middle,final),sep="_")
st_filtered<-st_filtered[,-c(6)]
#combine poppunk with st
st_poppunk<-inner_join(poppunk_clusters,st_filtered,by=c('id'='id_pop'))

#combine poppunk with st
st_poppunk<-inner_join(poppunk_clusters,st_filtered,by=c('id'='id_pop'))


#combine with continent and isolation source data
microreact_metadata<-inner_join(st_poppunk,host_continent,by=c('id_metadata'='assembly_accession'))

microreact_metadata<-microreact_metadata[,c(1,2,4,7,9,5,6)]

#get all the metadatatogether
all_metadata<-inner_join(important_metadata,microreact_metadata,by=c('assembly_accession'='id_metadata'))
write.csv(all_metadata,'../results/all_metadata.csv',row.names=FALSE)

names(microreact_metadata)<-c("id","Combined_Cluster__autocolour","ST__autocolour","continenet__autocolour","source__autocolour","id_metadata","long_id")

write.csv(microreact_metadata,'../results/microreact_metadata.csv',row.names=FALSE)
