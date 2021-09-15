#change underscores in name
cd ../results/raw_reads
files=$(ls *.fastq.gz)

for file in $files
do
accession=$(echo $file | cut -d '_' -f 1-3)
suffix=$(echo $file | cut -d _ -f 4)
new_accession=$(echo $accession | sed 's/_/-/g')
new_name=$(echo ${new_accession}_$suffix)
mv $file $new_name
done

