#!/bin/bash

#create output directory
mkdir -p ../results/rfplasmid_predictions
mkdir -p ../results/rfplasmid_scripts

#activate conda
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda activate rfplasmid

run_rfplasmid(){
cd ../results/rfplasmid_predictions
for strain in ../../$1; do
#check whether input directory exists
[ ! -d $strain ] && exit 1
name=$(basename $strain)
#run rfplasmid
echo "#!/bin/bash
cd ../rfplasmid_predictions
rfplasmid --species Enterobacteriaceae --input $strain --jelly --threads 8 --out $name" > ../rfplasmid_scripts/${name}.sh
done
}

#Run all the scripts
cd ../rfplasmid_scripts
for script in $(ls *.sh); do
sbatch --mem 5G --time 00:10:00 -c 8 $script
done

while getopts :i: flag; do
	case $flag in
		i) path=$OPTARG;;
	esac
done

#check if input is present
[ -z $path ] && exit 1

run_rfplasmid $path
