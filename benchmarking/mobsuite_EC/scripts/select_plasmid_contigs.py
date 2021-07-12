#import libraries
import fastaparser
import glob
import os

#Select plasmid contigs
#INPUT: name of assembly file
#OUTPUT: assembly file containing only contigs predicted as plasmids by the ensemble classifier
def select_plasmid_contigs(assembly_file):
	with open(assembly_file,'r') as fasta:
		assembly = fastaparser.Reader(fasta)
		for contig in assembly:
			if contig.id in plasmids:
				with open("../plasmid_scaffolds2/"+assembly_file,'a') as output:
					writer = fastaparser.Writer(output)
					writer.writefasta(contig)

#go to wd
wd='/home/dla_mm/lvader/data/ST131_repo/ST131_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds'
os.chdir(wd)

#make empty list
plasmids = []

#save contig headers of predicted plasmids in list
with open('../../../../benchmarking/analysis/results/EC_result_all_contigs2.csv','r') as EC_result:
	for line in EC_result.readlines():
		if 'plasmid' in line:
			contig_name=line.split(',')[0].strip('"')
			plasmids.append(contig_name)

#extract and save plasmid contigs for each assembly file
assembly_files=glob.glob('?RR*')
for file in assembly_files:
	with open("../plasmid_scaffolds2/"+file,'w') as output:
		pass
	select_plasmid_contigs(file)
	
