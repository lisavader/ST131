if (!require(ape)) install.packages("ape", repos = "http://cran.us.r-project.org")
require(ape)

#Get directory paths from input
arguments = commandArgs(trailingOnly=TRUE)
input_directory=arguments[1]
output_directory=arguments[2]

#Import snp dists file
snp_dists <- read.delim(input_directory)
row.names(snp_dists) <- snp_dists$snp.dists.0.8.2
snp_dists <- subset(snp_dists, select=-snp.dists.0.8.2)

#Build tree
tree <- nj(as.matrix(snp_dists))
#export in newick format
write.tree(tree, file = output_directory)
