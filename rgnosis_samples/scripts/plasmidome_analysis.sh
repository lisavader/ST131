#!/bin/bash

source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate panaroo

cd ../results/

move_files(){
mv bactofidia_output_all/scaffolds/predicted_plasmid_contigs plasmidome_all
}

run_prokka(){
cd plasmidome_all

mkdir -p annotations
mkdir -p prokka_scripts

#write scripts
for file in $(ls *.fasta); do
strain=$(basename $file .fasta)
echo "#!/bin/bash
cd ..
prokka --outdir annotations/$strain --strain $strain --prefix $strain --centre X --compliant --force $file" > prokka_scripts/${strain}.sh
done

#run scripts
cd prokka_scripts
for script in $(ls *.sh); do
sbatch -c 8 --time 00:30:00 --mem 10G $script
done

cd ..
}

run_plascope(){
cd plasmidome_all
panaroo -i annotations/*/*.gff -o panaroo_output --clean-mode sensitive
cd ..
}

#Run these:
move_files
run_prokka
run_plascope

