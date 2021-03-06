
#import libraries
import fastaparser
import glob
import os
import sys
import shutil

#set mode and dataset and define mode-specific variables
dataset=str(sys.argv[1])
mode=str(sys.argv[2])

base=mode.rsplit('_',1)[0]
print(base)

if "uni" in mode:
        EC_prediction='EC_uni_PS-PT-RF.csv'
elif "bac" in mode:
        EC_prediction='EC_bac_PS-PT-RF.csv'


def remove_chromosomal_contigs(strain):
	os.chdir(strain)
	bins=glob.glob('plasmid*')
	for bin in bins:
		with open(bin,'r') as fasta:
			os.makedirs("../../predictions_"+mode+"/"+strain,exist_ok=True)
			assembly = fastaparser.Reader(fasta)
			for contig in assembly:
				#for unicycler, merge strain and node nr. to obtain contig name
				if "uni" in mode:
					contig_name=strain+'_'+contig.id.split('_')[0]
				elif "bac" in mode:
					contig_name=contig.id
				if contig_name in plasmids:
					with open("../../predictions_"+mode+"/"+strain+"/"+bin,'a') as output:
						writer = fastaparser.Writer(output)
						writer.writefasta(contig)
	os.chdir('../')


#go to bins directory
#wd=os.path.dirname(os.path.realpath(__file__))
bins_dir='../results/'+dataset+'/predictions_'+base+'/'
print(bins_dir)
os.chdir(bins_dir)

#make empty list
plasmids = []

#remove previous results files, if they exist
shutil.rmtree("../predictions_"+mode+"/",ignore_errors=True)

#save contig headers of predicted plasmids in list
with open('../../../../binary_classifiers/results/'+EC_prediction,'r') as EC_result:
	for line in EC_result.readlines():
		if 'plasmid' in line:
			contig_name=line.split(',')[0].strip('"')
			plasmids.append(contig_name)

#then for each strain, go over the bins and only keep contigs that are in the previously defined plasmids list
strains=glob.glob('*')
for strain in strains:
	remove_chromosomal_contigs(strain)
