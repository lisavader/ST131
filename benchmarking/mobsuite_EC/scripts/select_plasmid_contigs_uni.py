#import libraries
import fastaparser
import glob
import os

#Select plasmid contigs
#INPUT: name of assembly file
#OUTPUT: assembly file containing only contigs predicted as plasmids by the ensemble classifier
def select_plasmid_contigs(strain):
	with open(strain+'/assembly.fasta','r') as fasta:
		assembly = fastaparser.Reader(fasta)
		for contig in assembly:
			contig_name=strain+'_'+contig.id
			if contig_name in plasmids:
				with open("plasmids/"+strain,'a') as output:
					writer = fastaparser.Writer(output)
					writer.writefasta(contig)

#go to wd
wd='/home/dla_mm/lvader/data/ST131_repo/ST131_ncbi_download/results/shortread_assemblies_unicycler'
os.chdir(wd)

#make empty list
plasmids = []

#save contig headers of predicted plasmids in list
with open('../../../benchmarking/analysis/results/EC_result_all_contigs3.csv','r') as EC_result:
	for line in EC_result.readlines():
		if 'plasmid' in line:
			contig_name=line.split(',')[0].strip('"')
			plasmids.append(contig_name)

#extract and save plasmid contigs for each assembly file
strains=glob.glob('?RR*')
for strain in strains:
	with open("plasmids/"+strain,'w') as output:
		pass
	select_plasmid_contigs(strain)
	
