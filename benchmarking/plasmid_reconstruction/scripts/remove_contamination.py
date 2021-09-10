
#import libraries
import fastaparser
import glob
import os
import sys

#set mode
mode=str(sys.argv[1])
base=mode.rsplit('_',1)[0]

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
				print(contig_name)
				if contig_name in plasmids:
					with open("../../predictions_"+mode+"/"+strain+"/"+bin,'a') as output:
						writer = fastaparser.Writer(output)
						writer.writefasta(contig)
	os.chdir('../')


#go to bins directory
#wd=os.path.dirname(os.path.realpath(__file__))
bins_dir='../results/predictions_'+base+'/'
os.chdir(bins_dir)

#make empty list
plasmids = []

#save contig headers of predicted plasmids in list
with open('../../../analysis/results/EC_result_all_contigs3.csv','r') as EC_result:
	for line in EC_result.readlines():
		if 'plasmid' in line:
			contig_name=line.split(',')[0].strip('"')
			plasmids.append(contig_name)

#then for each strain, go over the bins and only keep contigs that are in the previously defined plasmids list
strains=glob.glob('?RR*')
for strain in strains:
	remove_chromosomal_contigs(strain)
