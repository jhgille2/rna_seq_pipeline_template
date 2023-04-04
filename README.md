# rna_seq_pipeline_template
WIP reproducible pipeline for rna seq differential expression analysis. 

This repository is set up to be a template for an rna-seq/differential expression analysis to make it easeir to swap out data sources and re-run the analysis. The analysis workflow is currently managed with the [targets](https://books.ropensci.org/targets/) package through R. Dependency management can be done either through [conda](https://docs.conda.io/en/latest/) alone (faster), or through [singularity](https://singularity-userdoc.readthedocs.io/en/latest/) (if available). 

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
5. Modify the `parse_fq_files()` function in the **_targets.R** file as necessary to make a sample table for the workflow. **THIS PART IS REALLY IMPORTANT**. The workflow uses a table that has the sample name in the first column, the read 1 fastq file of the paired reads for the sample in the second column, and the read 2 fastq of the paired reads in the third column. If you'd prefer, this function can be replaced by reading in the sample table from a file e.g. `sample_table <- read.csv(sample_table.csv)`. In this case, remove the code that makes the sample table in the file.  
6. Run the pipeline by submitting the appropriate job to the scheduler.  
  a) conda: `sbatch job_conda.sh`.  
  b) singularity: `sbatch job_singularity.sh`.  

## Notes

### OS 
I developed this on Ubuntu 20.04 and CentOS. It may work on operating systems but I'm not sure. 

### Dependency management
If possible, use the singularity container for dependency management. The container the singularity_setup definition sets up is pretty simple, it just holds the conda environment defined in the environment.yml.  
  
**IMPORTANT**: It's probably best to build the singularity container on your personal computer and then transfer the conda.sif file that it makes to the main directory in the HPC where the rest of the files in this repo are copied to.  

If the HPC you are working on lets you make conda environments, make sure you check to see how they want you to make them/where to save them first. Most (probably all, really) have instructions about appropriate ways/places to install software.  

### Future work
This seems to be working pretty well, but long run I think [snakemake](https://snakemake.readthedocs.io/en/stable/) would be better in the long run since it can do everything I can do with targets but also includes way more tools for customizing the workflow and has a large community that actively uses it for bioinformatic analyses specifically. The only reason why I'm not using it right now in this repository is because I'm pretty bad at it right now. My plan is to eventually translate the workflow over to snakemake once I'm as comfortable with it as I am with targets.  

Organizing the files needed for the project in a [PEP](https://pep.databio.org/en/latest/) would be a good idea. This also fits in well with snakemake again as it's directly supported.

### Submission script
**job_conda.sh** and **job_singularity.sh** are set up to run on a cluster with a slurm scheduler, they'll have to be modified to work with other schedulers as appropriate before the pipeline can be run.  
