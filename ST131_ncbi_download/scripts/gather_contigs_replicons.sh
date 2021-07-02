#put all the quast all_alignments output files together and extract true lines
cd ../results/quast_output_bactofidia_contigs/ambiguity_all/ 

strains=$(ls)

for strain in $strains
do
cat ${strain}/contigs_reports/all_alignments_*.tsv | grep 'True' >> ../../bactofidia_all_true_alignments.tsv
done
