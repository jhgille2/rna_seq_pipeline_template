quantify_reads <- function(aligned_reads, transcriptome_file, sample_name){

    # Path to the directory to output files from the quantification
    outdir <- here::here("salmon_align_quant", sample_name)

    # Built the command
    cmd <- paste("salmon quant -l A",
                 "-a", aligned_reads,
                 "--targets", transcriptome_file,
                 "-o", outdir)

    # Run the command
    system(cmd)

    # Return the path to the quantification file output by the command
    out_file_path <- here::here(outdir, "quant.sf")
    return(out_file_path)
}
