#Extract reference ids headers and save as array
reference_ids=( $(cat GCA_900196535.2_ASM90019653v2_genomic.fna | grep '>' | cut -d ' ' -f 1 | sed 's/>//') )
#Calculate length of each replicon and save as array
lengths=( $(awk '/^>/ {if (seqlen){print seqlen};seqlen=0;next; } { seqlen += length($0)}END{print seqlen}' GCA_900196535.2_ASM90019653v2_genomic.fna) )

replicons=${#reference_ids[@]}-1 #number of replicons
echo $replicons
for i in {0..3}
do
echo ${reference_ids[$i]},${lengths[$i]}
done

