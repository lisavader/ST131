#!/bin/bash

#make results and scripts directory
mkdir -p ../results/platon_predictions
mkdir -p ../results/platon_scripts

#download database
mkdir -p ../databases/platon
cd ../databases/platon
if [[ ! -d db ]]; then
	wget https://zenodo.org/record/4066768/files/db.tar.gz
	tar -xzf db.tar.gz
	rm db.tar.gz
fi

#activate conda
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate platon

run_platon(){
cd ../../results/platon_predictions
#check whether input directory exists
[ ! -d ../../$1 ] && exit 1
#run platon on all strains in input directory
for strain in ../../$1/*.fasta
do
name=$(basename $strain .fasta)
echo "Running platon on" $name
platon --db ../../databases/platon/db --output $name --threads 8 $strain
done
}

run_platon_parallel(){
cd ../../results
#check whether input directory exists
#[ ! -d ../$1 ] && exit 1
#run platon on all strains in input directory
for strain in ../$1/*.fasta
do
name=$(basename $strain .fasta)
#For unicycler
#name=$(echo $strain | rev | cut -d '/' -f 2 | rev)
echo "#!/bin/bash
cd ../platon_predictions
platon --db ../../databases/platon/db --output $name --threads 8 ../$strain" > platon_scripts/${name}.sh
done

cd platon_scripts
for script in $(ls); do
echo "Running" ${script}"..." 
sbatch --time 1:00:00 --mem 5G -c 8 $script
done
}

while getopts :i: flag; do
	case $flag in
		i) path=$OPTARG;;
	esac
done

#check if input is present
[ -z $path ] && exit 1

run_platon $path
