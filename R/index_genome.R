index_genome <- function(genome_file, annotations_file, thread_num = 20){

    # Build system command from function input arguments
    cmd <- paste(
        "STAR --runThreadN", thread_num,
        "--runMode genomeGenerate",
        "--genomeSAindexNbases 12",
        "--genomeDir starindices/ --genomeFastaFiles", genome_file,
        "--sjdbGTFfile", annotations_file,
        "--sjdbOverhang 36"
    )

    system(cmd)

    # Return paths to all files output by the function
    return(list.files(here::here("starindices"), full.names = TRUE))
}