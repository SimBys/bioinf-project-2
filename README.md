# bioinf-project-2

Analysis of sequencing data of cancerous and normal (reference) samples from a human patient. 

## 1. Raw Data Quality Control

We generated a Fastqc Quality Report for each sample with the `fastqc` command.

The reports are in the `raw_data_quality_control` directory.

No sequences were flagged as poor quality and per base quality scores were almost all above 30,
which is considered good.

In the reference sample, the quality per tile was not optimal for some tiles.

Per sequence GC content lines are not smooth with more than 1 peak, which could indicate the samples were contaminated.

## 2. Read Alignment

For alignment we used the `hg38` reference genome.

We aligned the samples with the `bwa mem` command.

We stored the result in `.bam` format for compact and efficient worflow.

## 3. Postprocessing

We **sorted** the `.bam` files by coordinate with the `samtools sort` command.

Then we removed duplicates with the `samtools markdup` command.

Afterward we recalibrated base quality scores using `GATK`.

## 4. Post-Alignment Quality Control

## 5. Variant Calling

## 6. Post-Processing and Annotation

## 7. Results
