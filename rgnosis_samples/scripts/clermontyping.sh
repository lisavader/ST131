#!/bin/bash

source ~/data/miniconda3/etc/profile.d/conda.sh

build_environment(){
conda create --name clermontyping
conda activate cermontyping
conda install -c kantorlab blastn
conda install -c anaconda biopython
conda install -c conda-forge/label/cf201901 pandoc
conda install -c conda-forge r-readr r-dplyr r-tidyr r-stringr r-knitr r-rmarkdown
}

clone_clermontyping(){
cd ../tools
git clone https://github.com/A-BN/ClermonTyping clermontyping
}

run_clermontyping(){
cd ../tools/clermontyping
#soft link fasta fils
ln -s ../../results/bactofidia_output_all/scaffolds/*.fasta .
#build input string of fasta files separated by a @ character
fasta_files=$(ls -1 *.fasta | tr '\n' '@')
fasta_files=${fasta_files%?}
#run clermontyping
conda activate clermontyping
bash clermonTyping.sh --fasta $fasta_files --name clermontyping_output
mv clermontyping_output ../../results
}

#Run:
build_environment
clone_clermontyping
run_clermontyping
