#download rfplasmid
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
#conda create -n rfplasmid -c conda-forge -c bioconda rfplasmid
conda activate rfplasmid
#rfplasmid --initialize

#run rfplasmid
mkdir ../results/rfplasmid_predictions
cd ../results/rfplasmid_predictions

rfplasmid --species Enterobacteriaceae --input ../../../../ST131_ncbi_download/results/shortread_assemblies_bactofidia/scaffolds --jelly --threads 8 --out .
