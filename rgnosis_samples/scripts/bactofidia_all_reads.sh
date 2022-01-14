cd ../..bactofidia
ln -s ~/data/raw_reads/3rd_run/* .
ln -s ~/data/raw_reads/st131_confirmed/* .
sbatch -J bactofidia_ST131_all_reads --time 96:00:00 --mem 40G -c 8 ./bactofidia.sh *.fastq.gz
