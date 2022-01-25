#save cpu and memory info
#specify your own list of slurm output files

print_header=$true

for slurm_file in your_slurm_output_files; do
        summary=$(sacct --jobs=$slurm_file --format="JobId,Elapsed,NCPUS,CPUTime,MaxRSS")
        #the first time, print the header
        if [ $print_header = true ]; then
                cat $summary | grep Job >> ../results/cpu_memory_records.txt
        fi
        #otherwise only save the last line
        cat $summary | tail -n 1 >> ../results/cpu_memory_records.txt
        print_header=$false
done