do_multiqc <- function(fastqc, outdir){
    cmd <- paste(
        "multiqc",
        here::here("fastqc"),
        "-o", outdir
    )
    system(cmd)
}