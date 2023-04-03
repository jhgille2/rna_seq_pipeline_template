# rna_seq_pipeline_template
WIP reproducible pipeline for rna seq differential expression analysis. 

This repository is set up to be a template for an rna-seq/differential expression analysis to make it easeir to swap out data sources and re-run the analysis. The analysis workflow is currently managed with the [targets](https://books.ropensci.org/targets/) package through R. Dependency management can be done either through conda alone (faster), or through singularity (if available). 

## Directory overview
**R**: All the R functions used in the pipeline are stored here. There is one file per function.   
**_targets**: A folder that holds the meta-data for the targets workflow manager.   
**_targets.R**: The control script/makefile for the workflow.  
**clustermq.tmpl**: Template for variable substitution to use for exectuion on HPC with the clustermq interface to schedulers.  
**environment.yml**: A conda environment file that lists the required packages + their versions that are required.  
**job.sh**: Script for submitting the workflow as a batch job to HPC.   
**make_folders.sh**: Bash script to create the other folders that are needed for the workflow.  
**packages.R**: R script with the R packages that are needed for running/debugging the pipeline in interactive R mode.  
**run.R**: The script that actually runs the pipeline.  
**run.sh**: Bash script to run the pipeline in interactive command line mode.  
**singularity_setup**: Singularity definition file that can be used to make a singularity container with the conda environemnt defined by **environment.yml**

# Setup
The pipeline is not ready to run right out of the gate, theres a few checks and things that need to be set up first.   
0. Clone this directory to an appropriate location with `git clone https://github.com/jhgille2/rna_seq_pipeline_template.git`  
1. Directories to hold the input/output of the pipeline need to be added. Run `bash make_folders.sh` to add them all at once.  
2. Decide on what system you want to use for dependency management.  
  a) Conda: Create a conda environment from the **environment.yml** file with `conda env create -f environment.yml`.  
  b) Singularity: Have to have singularity installed and sudo permissions, then run `sudo singularity build conda.sif singularity_setup`.  
3. Copy data into appropriate directories.
  a) ./data: The genome .fa and annotations .gtf file
  b) ./data/reads: rna seq fastq files
  c) ./transcriptome: transcriptome .fa file
4. Edit the **_targets.R** file to point to the correct files. 
  a) **genome_file** target should point to the genome .fa file.  
  b) **annotations_file** target should point to the annotations .gtf file  
  c) **transcriptome_file** target should point to the transcriptome .fa file
5. Modify the `parse_fq_files()` function in the **_targets.R** file as necessary to make a sample table for the workflow. **This part is really important**. The workflow uses a table that has the sample name in the first column, the read 1 fastq file of the paired reads for the sample in the second column, and the read 2 fastq of the paired reads in the third column. If you'd prefer, this function can be replaced by reading in the sample table from a file e.g. `sample_table <- read.csv(sample_table.csv)`. In this case, remove the code that makes the sample table in the file.  
6. Run the pipeline by submitting the appropriate job to the scheduler.  
  a) conda: `sbatch job_conda.sh`.  
  b) singularity: `sbatch job_singularity.sh`.  

