#!/bin/bash

cd ~/data/genome_download
accessions=$(cat ST131_accessions07042021)

for strain in $accessions:
do
esearch -db assembly -query ${strain} | elink -target nuccore | efetch -format gb  > accessions/${strain}.txt
done

