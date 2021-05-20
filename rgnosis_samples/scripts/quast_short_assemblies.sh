cd ~/data
conda activate quast

ncbi-genome-download --formats fasta bacteria -A GCF_015277555.1

cd quast
ln -s ~/data/refseq/bacteria/GCF_015277555.1/GCF_015277555.1_ASM1527755v1_genomic.fna.gz .
ln -s ~/data/bactofidia_ST131/202103232141_results/scaffolds/ scaffolds_23032021
quast -r GCF_015277555.1_ASM1527755v1_genomic.fna.gz scaffolds_23032021/UNK-JSC-RGN-105342.fna scaffolds_23032021/ECO-JSC-RGN-105296.fna scaffolds_23032021/UNK-JSC-RGN-105477.fna scaffolds_23032021/UNK-JSC-RGN-105478.fna scaffolds_23032021/UNK-JSC-RGN-105476.fna scaffolds_23032021/UNK-JSC-RGN-105475.fna


