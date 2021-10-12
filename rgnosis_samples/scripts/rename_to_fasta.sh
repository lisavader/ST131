#Rename assembly files to .fasta
cd ../results/bactofidia_output_ST131/scaffolds/
for name in $(ls); do new_name=$(echo $name | sed 's/.fna/.fasta/'); mv $name $new_name; done

