cd ../sra_files

#Rename sra files so that they are _R1.fasta instead of _1.fasta
#I don't know whether this is actually necessary
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

#Run bactofidia as normal
cd ~/data/bactofidia
ln -s ~/data/ST131_repo/ST131_ncbi_download/sra_files/*.fastq.gz .
sbatch --time 32:00:00 --mem 32G -c 8 bactofidia.sh ALL
