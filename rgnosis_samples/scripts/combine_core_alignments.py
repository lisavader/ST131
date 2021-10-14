
import fastaparser
import os
import glob

def find_strains(fasta_dir):
	'''
	Returns a list with all strains.
		
		Parameters: 
			fasta_dir (str): Path to directory containing assemblies in .fasta format
		
		Returns: 
			strains (list): List with strain names

	'''
	strains = []

	os.chdir(fasta_dir)
	fasta_files=glob.glob("*")
	for file in fasta_files:
		strain=file.strip(".fasta")
		strains.append(strain)
	return(strains)

def write_all_sequences(strain,output_file):
	'''
	Writes all sequences belonging to a strain in the output file
		
		Parameters: 
			strain (str): Name of the strain
			output_file (str): Path to output directory, from alignments directory
		
		Returns: 
			None

	'''
	
	#write strain header
	with open(output_file, 'a') as output:
		output.write("\n>"+strain+"\n")	
	
	#for each alignment file, find the sequence belonging to the strain and write it
	genes=glob.glob("*")
	for gene_alignment in genes:
		with open(gene_alignment, 'r') as fasta:
			reader = fastaparser.Reader(fasta)
			for sequence in reader:
				if strain in sequence.id:
					print(strain, gene_alignment, sequence.id)
					with open(output_file, 'a') as output:
						output.write(sequence.sequence_as_string())

#variables
alignments_dir="../results/panaroo_output/aligned_gene_sequences"
fasta_dir="../results/bactofidia_output_ST131/scaffolds"
output_file="../all_alignments.aln.fas"

wd=os.path.dirname(os.path.realpath(__file__))

##Main script
strains = find_strains(fasta_dir)
os.chdir(wd)
os.chdir(alignments_dir)
#overwrite output file, in case an old one exists
with open(output_file, 'w') as output:
	pass
for strain in strains:
	write_all_sequences(strain,output_file)

