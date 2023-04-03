align_reads <- function(sample_name, read_1, read_2,
                        genome_index, seq_files, thread_num = 20){

    # Output file prefix
    out_file_prefix <- here::here("AlignedToTranscriptome", sample_name)

    # Full paths to read files
    full_read_1 <- here::here("data", "reads", read_1)
    full_read_2 <- here::here("data", "reads", read_2)

    # Paste together the command
    cmd <- paste(
        "STAR --runThreadN", thread_num,
        "--runMode alignReads",
        "--genomeDir starindices",
        "--outFileNamePrefix", out_file_prefix,
        "--readFilesIn", full_read_1, full_read_2,
        "--readFilesCommand zcat",
        "--outSAMtype BAM Unsorted",
        "--twopassMode Basic",
        "--quantMode TranscriptomeSAM"
    )

    # Run the command
    system(cmd)

    # Return the path to the output bam file
    out_file <- paste0(out_file_prefix, "Aligned.toTranscriptome.out.bam")
    return(out_file)
}