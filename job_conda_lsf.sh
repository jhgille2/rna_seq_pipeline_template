#!/bin/bash

# Submit the pipeline as a job with srun job.sh

# Modified from https://github.com/mschubert/clustermq/blob/master/inst/LSF.tmpl
# under the Apache 2.0 license:
#BSUB -J soy_test_alignment
#BSUB -o out.%J
#BSUB -e err.%J
#BSUB -n 72
#BSUB -x
#BSUB -W 12:00

module load R
module load miniconda
source activate bit_cpt_final
R CMD BATCH run.R

# Removing .RData is recommended.
# rm -f .RData