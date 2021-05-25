
#Rename sra files so that they are _R1.fasta instead of _1.fasta
files=$(ls *.fastq)

for file in $files
do
accession=$(echo $file | cut -d _ -f 1)
suffix=$(echo $file | cut -d _ -f 2)
new_name=$(echo $accession'_R'$suffix)
mv $file $new_name
done

#Gzip sra files because bactofidia needs it
#but takes a long time, so would rather have a different solution
gzip *.fastq

#Run bactofidia with group installation
screen -S bactofidia
srun --gres=tmpspace:4G --mem=32G --time=32:00:00 -c 8 --pty bash
bactofidia-stable ALL
