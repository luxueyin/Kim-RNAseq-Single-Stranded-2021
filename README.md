# Kim_RNAseq_Single_Stranded
Pipeline for processing single-stranded RNA sequencing

Processing RNA-seq SE files sourced from: https://www.sciencedirect.com/science/article/pii/S2211124721007555.

The RNAseq dataset is downloaded from published PE RNA-seq files from GEO Accession (https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE174583) for wt and Brg1cko samples, (https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE174584) for wt, SA (Brg1-S1382A) and SE (Brg1-S1382E) samples. They are then processed for QC, aligning and analysis in Rstudio. The analysis is setup to run on the DMCBH Alder computing cluster using bash scripts.

## Step 1: Fetching Data from GEO

The data is stored under 2 separate NCBI GEO as SRR files which are highly compressed files that can be converted to fastq files using SRA Toolkit: https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA730576&o=acc_s%3Aa and https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA730578&o=acc_s%3Aa.

To download a text file of SRR files, use the Run Select function. Navigate to the bottom of the page and select all the RNA-seq data. Download "Accession List".

### Make a directory for the experiment in your home directory

```
cd ~/ && mkdir Kim_RNAseq
```

Make a copy of the SRR_Acc.List.txt file in your home directory.

```
cd ~/Kim_RNAseq
nano SRR_Acc_List.txt
```

### Run the SRRpull.sh script

The script is setup to run from the experiment directory inside the home directory.

It makes a SRA directory in the experiment directory and uses a loop to pull each SRR file in SRR_Acc_List.txt using prefetch.

Make a SRRpull.sh script in the experiment directory and run the script as sbatch submission to Alder.

```
sbatch SRRpull.sh
```

Once the script has finished running, make sure to check all the SRA files have been successfully copied over.

cd ~/Wenderski_RNAseq/SRA/SRA_checksum/SRAcheck.log

Make sure ALL files have 'OK' and "Database 'SRRNAME.sra' is consistent" listed. Need to rerun SRRpull.sh script if encountered any errors.

## Step 2: QC of Fastq Files Prior to Trimming

We need to check the quality of the fastq files before and after trimming. We are using FastQC from https://www.bioinformatics.babraham.ac.uk/projects/fastqc/. Refer to their tutorial for output file interpretations.

Run the following script to perform quality check on the fastq files prior to trimming.

```
sbatch pretrim_fastqc.sh
```

Check PretrimFastQC_multiqc_report.html for details of sequence quality.

## Step 3: Trimming fastq files

We need to remove adapters and poor quality reads before aligning.

Trimmomatic will look for seed matches of 16 bases with 2 mismatches allowed and will then extend and clip if a score of 30 for PE or 10 for SE is reached (~17 base match).

Minimum adapter length is 8 bases.

T = keeps both reads even if only one passes critieria.

Trims low quality bases at leading and trailing if quality score < 15.

Sliding window: scans in a 4 base window, cuts when the average quality drops below 15.

Log outputs number of input reads, trimmed, and surviving reads in the trim_log_samplename.

It uses TruSeq3-PE.fa (comes with Trimmomatic download).

The path is set in bash_profile with $ADAPTERS To check the content of the file:

```
less $ADAPTERS/TruSeq3-PE.fa
```

Run the script.

```
sbatch trim.sh
```

## Step 4: Repeat QC on post trim file

This step is the same as pretrim.

```
sbatch posttrim.sh
```

## Step 5: QC of Fastq Files: Contamination Screening


FastQ Screen is an application allowing us to search a large sequence dataset against a panel of different genomes to determine from where the data originate.

The program generates both text and graphical output to inform you what proportion of the library was able to map, either uniquely or to more than one location, against each of the specified reference genomes.

Run script to check trimmed fastq files.

```
sbatch fastqscreen.sh
```

The output is found in output/FastqScreen_multiqc_report.html

## Step 6: Align to mm10 genome using STAR

### Generating star index

We first need to generate star indices for efficient mapping of RNA-seq fastq data to the indexed reference genome. This may have already been done, but be sure to double check the sequencing length to optimize alignment.

In desired directory, run the following script for setting up genome sequence, annotation, and star indices. The star index is optimized for 50bp sequencing data. Edit --sjdbOverhang for alternative read lengths. Ideally, this length should be equal to the ReadLength-1, where ReadLength is the length of the reads. For more information: https://physiology.med.cornell.edu/faculty/skrabanek/lab/angsd/lecture_notes/STARmanual.pdf.


## Step 7: Differential Expression Analysis Using Rstudio

See attached Kim_RNAseq_SA_SE.R script for differential Expression Analysis using Rstudio.

Pathways to files is likely different and would need to be updated accordingly to allow scripts to run properly.

