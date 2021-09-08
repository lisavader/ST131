# -*- coding: utf-8 -*-
"""
Author: Julian Paganini
Modified by: Lisa Vader
"""

import sys
import os
import glob
import fastaparser

wd=os.path.dirname(os.path.realpath(__file__))
os.chdir(wd)
os.chdir('../results/predictions_spades')
genomes=glob.glob('?RR*')


def organize_genome(input_folder):
    strain=input_folder
    components=set()

    #Parse fasta files in quick way a quick way.
    with open(input_folder+"/contigs.fasta") as fasta_file:
        parser = fastaparser.Reader(fasta_file, parse_method='quick')
        #loop thru the headers and and create a set with all the components
        for seq in parser:
            plasmid_bin=seq.header.split('_')[6:8]
            plasmid_bin='_'.join(plasmid_bin)
            # seq is a namedtuple('Fasta', ['header', 'sequence'])
            components.add(plasmid_bin)
        
        #loop thru the set to create a new fasta file for each component
        for bins in components:
            search=bins
            with open(input_folder+'/'+strain+'_'+search+'.fasta', 'w') as bin_file:	#create empty file
                pass	
            with open(input_folder+'/'+strain+'_'+search+'.fasta', 'a+') as bin_file:
                for seq in parser:
                    if search in seq.header:
                        bin_file.write(seq.header)
                        bin_file.write('\n')
                        bin_file.write(seq.sequence)
                        bin_file.write('\n')
                    else:
                        continue
            
            bin_file.close()
                    
    
       
for files in genomes:
	try:
		organize_genome(files)
	except:
		print("Error in organize_genome("+files+").")

