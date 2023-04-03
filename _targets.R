## SECTION: Setup
################################################################################
## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

# A function to help with making a sample table from the input reads
parse_fq_files <- function(fq_file_name) {

    # Split the name on underscores
    split_file_name <- stringr::str_split(fq_file_name, "_")

    # Get just the sample name
    sample_name <- paste(split_file_name[[1]][1:3], collapse = "_")

    # Get the read number (1 or 2)
    read_num <- stringr::str_sub(split_file_name[[1]][4], 1, 1)

    # Combine them all into a table and return
    res <- tibble::tibble(
        sample_name = sample_name,
        read_num = read_num,
        full_name = fq_file_name
    )

    return(res)
}

# Now use the function to make a sample table that can be used for branching
# Sample table with paths to reads for static branching over paired reads
paired_reads_table <- map(list.files(here::here("data", "reads")), parse_fq_files) %>% # nolint
    purrr::reduce(bind_rows) %>%
    pivot_wider(names_from = read_num, values_from = full_name, names_prefix = "read_") %>% # nolint 
    dplyr::filter(!sample_name %in% c("Gm_SA_Rep5", "Gm_SA_Rep2"))

# A table with just the sample names
sample_table <- paired_reads_table %>%
    select(sample_name) %>%
    distinct()

# START: Workflow definition
################################################################################
## tar_plan supports drake-style targets and also tar_target()
tar_plan(

## SECTION: File path definitions
################################################################################
    # The rna-seq reads
    tar_file(seq_files,
             list.files(here::here("data", "reads"), full.names = TRUE)),

    # The genome file
    tar_file(genome_file,
            here::here("data", "genome.fna")),

    # Annotations file
    tar_file(annotations_file,
              here::here("data", "genomic_no_wait_actually_use_this_one.gtf")),

    # Transcriptome file
    tar_file(transcriptome_file,
             here::here("data", "transcripts_filtered.fa")),

## SECTION: Analysis
################################################################################
    # There seems to be an issue with the genomic.gtf file that prevents 
    # the transcriptomes from being extracted that (may)
    # Run fastqc on all reads
    tar_file(fastqc,
             do_fastqc(seq_files,
                       thread_num = 30,
                       outdir = here::here("fastqc"))),

    # Multiqc report for the fastqc reports
    tar_target(multiqc,
                do_multiqc(fastqc,
                           outdir = here::here("multiqc_reports", "fastqc"))),

    # Index genome
    tar_file(genome_index,
               index_genome(genome_file, annotations_file)),

    # Align reads to the indexed genome
    # tar_map runs the align_reads function for each
    # row in the paired_reads_table table
    quantification_files <- tar_map(

        # The table that holds the parameters to the align_reads
        # function (the experimental design table)
        values = paired_reads_table,

        # Definition of the alignment target
        tar_file(aligned_reads,
                    align_reads(sample_name,
                                read_1,
                                read_2,
                                genome_index,
                                seq_files,
                                thread_num = 50
                    )
        ),

        # Quantify with salmon
        tar_file(quantified_reads,
                 quantify_reads(aligned_reads,
                                transcriptome_file,
                                sample_name))

    ),

    # Combine the paths to the alignment files into a list
    tar_combine(all_quantification_files,
		quantification_files[[2]],
		command = list(!!!.x))

)
