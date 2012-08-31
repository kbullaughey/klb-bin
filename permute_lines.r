the.args <- commandArgs()
infile <- as.numeric(sub("--infile=", "", the.args[grep("--infile=", the.args)]))
outfile <- as.numeric(sub("--outfile=", "", the.args[grep("--outfile=", the.args)]))
stopifnot(length(infile) > 0)
stopifnot(length(outfile) > 0)

lines <- readLines(infile)
cat(paste(lines[sample(1:length(lines), length(lines), replace=FALSE)], 
   "\n", sep=""), sep="", file=outfile)
