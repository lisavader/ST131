#!/bin/bash

##Estimate pangenome size

mkdir ../results/panaroo_output/img_results
panaroo-img --pa ../results/panaroo_output/gene_presence_absence.Rtab -D 2 -o ../results/panaroo_output/img_results --tree dated_phylogeny.newick
