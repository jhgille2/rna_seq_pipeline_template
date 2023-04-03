do_fastqc <- function(seq_files, thread_num, outdir){

    # Concatenate all the file paths to the sequence files
    all_seq_files <- paste(seq_files, collapse = " ")

    # Build command
    cmd <- paste("fastqc", all_seq_files, "-t", thread_num, "-outdir", outdir)

    # Run command
    system(cmd)

    # Return paths to output files
    return(list.files(outdir, full.names = TRUE))
}