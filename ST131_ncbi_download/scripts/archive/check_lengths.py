import fastaparser

with open('DRR192221.fna','r') as fasta:
	assembly = fastaparser.Reader(fasta)
	for contig in assembly:
		length=len(contig.sequence)
		print(length)
