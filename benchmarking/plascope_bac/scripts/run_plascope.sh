#install plascope via conda
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
#conda create --name plascope -c bioconda plascope
conda activate plascope

#download E. coli database
mkdir ../data
cd ../data
#wget https://zenodo.org/record/1311641/files/chromosome_plasmid_db.tar.gz
tar -xzf chromosome_plasmid_db.tar.gz
rm chromosome_plasmid_db.tar.gz

#run plascope
mkdir ../results/plascope_predictions
cd ../results/plascope_predictions

for file in  ../../../../ST131_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds/*.fna
do
name=$(basename $file .fna)
plaScope.sh --fasta $file -o . --db_dir ../../data --db_name chromosome_plasmid_db --sample $name
done
