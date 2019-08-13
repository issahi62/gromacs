library(ape)


ifn <- "thomas.fas.txt"
ofn <- "mers.fas.long"
thresh <- 29000

s <- read.dna(ifn,format="fasta",as.matrix=FALSE)
nm <- names(s)
names(s) <- gsub("/","-",nm,fixed=TRUE)
l <- unlist(lapply(s,length))
s <- s[l>=thresh]

write.dna(s,ofn,format="fasta",nbcol=-1,colsep="")

