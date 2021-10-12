
import fastaparser
import os
import glob


def find_strains(fasta_dir):
	strains = []

	os.chdir(fasta_dir)
	fasta_files=glob.glob("*")
	for file in fasta_files:
		strain=file.strip(".fasta")
		strains.append(strain)
	return(strains)

def write_all_sequences(strain,output_file):

	with open(output_file, 'a') as output:
		output.write(">"+strain+"\n")	
	
	genes=glob.glob("*")
	for gene_alignment in genes:
		with open(gene_alignment, 'r') as fasta:
			reader = fastaparser.Reader(fasta)
			for sequence in reader:
				if strain in sequence.id:
					with open(output_file, 'a') as output:
						output.write(sequence.sequence_as_string())

#variables
alignments_dir="../results/panaroo_output/aligned_gene_sequences"
fasta_dir="../results/bactofidia_output_ST131/scaffolds"
output_file="all_aligned_genes.aln.fas"

wd=os.path.dirname(os.path.realpath(__file__))

#main script
strains = find_strains(fasta_dir)
os.chdir(wd)
os.chdir(alignments_dir)
with open(output_file, 'w') as output:
	pass
for strain in strains:
	write_all_sequences(strain,output_file)

