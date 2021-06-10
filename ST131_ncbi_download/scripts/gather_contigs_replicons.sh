
cd ../results/quast_output_bactofidia_contigs

strains=$(ls)

for strain in $strains
do
cat ${strain}/contigs_reports/all_alignments_*.tsv | grep -v CONTIG | cut -f 5,6 | grep cov | uniq >> ../bactofidia_contigs_mapped.tsv
done
