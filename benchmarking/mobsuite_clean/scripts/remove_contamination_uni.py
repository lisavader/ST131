
#import libraries
import fastaparser
import glob
import os

def remove_chromosomal_contigs(strain):
	os.chdir(strain)
	bins=glob.glob('plasmid*')
	for bin in bins:
		with open(bin,'r') as fasta:
			os.makedirs("../../../../mobsuite_clean/results/mob_predictions_clean3/"+strain,exist_ok=True)
			assembly = fastaparser.Reader(fasta)
			for contig in assembly:
				contig_name=strain+'_'+contig.id.split('_')[0]
				print(contig_name)
				if contig_name in plasmids:
					with open("../../../../mobsuite_clean/results/mob_predictions_clean3/"+strain+"/"+bin,'a') as output:
						writer = fastaparser.Writer(output)
						writer.writefasta(contig)
	os.chdir(wd)


#go to wd
wd='/home/dla_mm/lvader/data/ST131_repo/benchmarking/mobsuite/results/mob_predictions'
os.chdir(wd)

#make empty list
plasmids = []

#save contig headers of predicted plasmids in list
with open('../../../analysis/results/EC_result_all_contigs3.csv','r') as EC_result:
	for line in EC_result.readlines():
		if 'plasmid' in line:
			contig_name=line.split(',')[0].strip('"')
			plasmids.append(contig_name)

strains=glob.glob('?RR*')
for strain in strains:
	remove_chromosomal_contigs(strain)
