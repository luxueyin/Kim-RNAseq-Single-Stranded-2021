#!/bin/bash
#
#SBATCH -c 4
#SBATCH --mem-per-cpu=2000
#SBATCH --job-name=gunzip
#SBATCH --output=trimmed_unzip.out
#SBATCH --time=2:00:00

#######################################################################################
mkdir -p trimmed_unzip

for sample in `cat SRR_Acc_List.txt`
do

echo ${sample} "starting unzip"

# -c keep original files unchanged
gunzip -c trimmed/${sample}.fastq.gz > trimmed_unzip/${sample}.fastq

echo ${sample} "finished unzip"

done