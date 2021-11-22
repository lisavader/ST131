#import libraries
import fastaparser
import glob
import os
import sys
import shutil

#set dataset and mode and assign mode-specific variables
dataset=str(sys.argv[1])
mode=str(sys.argv[2])

if "uni" in mode:
	assemblies_dir='../../../'+dataset+'_ncbi_download/results/shortread_assemblies_unicycler/'
	EC_prediction_path='../../../benchmarking/binary_classifiers/results/EC_uni_PS-PT-RF.csv'
	if "ST131" in dataset:
		assembly_wildcard="?RR*"
	elif "Ecoli" in dataset:
		assembly_wildcard="GCA*"

elif "bac" in mode:
	assemblies_dir='../../../'+dataset+'_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds/'
	EC_prediction_path='../../../../benchmarking/binary_classifiers/results/EC_bac_PS-PT-RF.csv'
	assembly_wildcard='*.fasta'

#Select plasmid contigs
#INPUT: name of assembly file
#OUTPUT: assembly file containing only contigs predicted as plasmids by the ensemble classifier
def select_plasmid_contigs(strain):
	if "uni" in mode:
		assembly_file=strain+'/assembly.fasta'
	elif "bac" in mode:
		assembly_file=strain
	with open(assembly_file,'r') as fasta:
		assembly = fastaparser.Reader(fasta)
		for contig in assembly:
			#for unicycler, merge strain with contig id to obtain contig name
			if "uni" in mode:
				contig_name=strain+'_'+contig.id
			elif "bac" in mode:
				contig_name=contig.id
			if contig_name in plasmids:
				with open("predicted_plasmid_contigs/"+strain,'a') as output:
					writer = fastaparser.Writer(output)
					writer.writefasta(contig)


#go to assemblies directory
os.chdir(assemblies_dir)

#make empty list
plasmids = []

#save contig headers of predicted plasmids in list
with open(EC_prediction_path,'r') as EC_result:
	for line in EC_result.readlines():
		if 'plasmid' in line:
			contig_name=line.split(',')[0].strip('"')
			plasmids.append(contig_name)

#make new directory for storing the results, if it already exists remove previous one
if os.path.exists("predicted_plasmid_contigs/"):
	shutil.rmtree("predicted_plasmid_contigs/") 
os.makedirs("predicted_plasmid_contigs/")

#extract and save plasmid contigs for each assembly file
strains=glob.glob(assembly_wildcard)
for strain in strains:
	with open("predicted_plasmid_contigs/"+strain,'w') as output:
		pass
	select_plasmid_contigs(strain)
	
