#Gzip all .fastq files

cd ../results/raw_reads
mkdir ../gzip_scripts

files=$(ls *.fastq)

for file in $files
do
echo "#!/bin/bash
cd ../raw_reads
gzip $file" > ../gzip_scripts/${file}.sh
done

cd ../gzip_scripts
jobs=$(ls)

for script in $jobs
do
sbatch --mem 10G --time 00:30:00 -c 8 $script
done
