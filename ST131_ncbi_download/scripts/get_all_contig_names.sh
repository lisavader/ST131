for file in $(ls); do cat $file | grep '>' >> ../all_contig_names.txt; done
