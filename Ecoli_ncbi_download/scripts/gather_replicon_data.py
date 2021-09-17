#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Lisa Vader
"""

#import libraries
import fastaparser
import glob
import os

#Get replicon info
#INPUT: assembly_accession
#OUTPUT: for each replicon, prints the assembly_accession, reference_id, replicon length and classification 
#(plasmid or chromosome) as a line in replicon_data.csv
def get_replicon_info(accession):

	#Get replicon info using fastaparser
	with open(accession+'_genomic.fna','r') as fasta:
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
				output.write(accession+','+reference_id+','+str(length)+','+classification+'\n')

#define directory paths
wd='../results/'
genomes_directory='genomes'

os.chdir(wd)

#create output files
with open('replicon_data.csv', 'w') as output:
	pass

#For each accession provided, get replicon info and write to file
with open('benchmark_strains.csv') as accessions:
	for line in accessions.readlines():
		#remove new line chr
		accession=line.replace("\n", "")
		#run get replicon function
		os.chdir(genomes_directory)
		get_replicon_info(accession)
		os.chdir('../')

