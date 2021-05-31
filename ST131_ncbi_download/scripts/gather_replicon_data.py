#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Lisa Vader
"""

#import libraries
import fastaparser
import glob
import os

#Get assembly accession
#INPUT: sra_accession
#OUTPUT: assembly_accession
def get_assembly_accession(sra_accession): 
	with open('accessions_table.csv', 'r') as accessions_table:
		for line in accessions_table.readlines():
			if sra_accession in line:
				assembly_accession=line.split(',')[0]	
				return assembly_accession

#Get replicon info
#INPUT: assembly_accession
#OUTPUT: for each replicon, prints the assembly_accession, reference_id, replicon length and classification 
#(plasmid or chromosome) as a line in replicon_data.csv
def get_replicon_info(assembly_accession):
		
	#Get full file name of assembly
	assembly_file=glob.glob(assembly_accession+"*")[0]

	#Get replicon info using fastaparser
	with open(assembly_file,'r') as fasta:
		assembly = fastaparser.Reader(fasta)
		for replicon in assembly:
			reference_id=replicon.id
			if 'plasmid' in replicon.description:
				classification='plasmid'
			else:
				classification='chromosome'
			length=len(replicon.sequence)
		
			#Write to file
			with open('../replicon_data.csv', 'a+') as output:
				output.write(assembly_accession+','+reference_id+','+str(length)+','+classification+'\n')

#define directory paths
wd='home/dla_mm/lvader/data/ST131_repo/ST131_ncbi_download/results')
genomes_directory='genomes'

os.chdir(wd)

#create output files
with open('replicon_data.csv', 'w') as output:
	pass

#For each sra_accession provided, convert to assembly accession and write replicon info to file
with open('longread_ST131_sra_accessions') as sra_accessions:
	for line in sra_accessions.readlines():
		assembly_accession=get_assembly_accession(line)
	
		#If the assembly_accession has already been evaluated: Skip
		with open('replicon_data.csv', 'r') as output:
			if assembly_accession in output.read():
				continue
	
		#Otherwise: Get replicon info and write to file
		os.chdir(genomes_directory)
		get_replicon_info(assembly_accession)
		os.chdir(wd)

