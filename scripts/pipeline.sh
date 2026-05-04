#!/bin/bash
# Bioinformatics Pipeline - Project 2
# Sample: S17

# === VARIABLES ===
REF=~/Desktop/project/reference/hg38.fa
DATA=~/Desktop/project/data
BAM=~/Desktop/project/results/bam
MARKDUP=~/Desktop/project/results/markdup
VCF=~/Desktop/project/results/vcf

# === STEP 1: FastQC ===
fastqc $DATA/*.fastq.gz -o results/fastqc/ -t 4

# === STEP 2: Alignment ===
bwa mem -t 8 -R '@RG\tID:normal\tSM:normal\tPL:ILLUMINA' \
    $REF $DATA/S17.C_R1.fastq.gz $DATA/S17.C_R2.fastq.gz \
    > $BAM/normal.sam

bwa mem -t 8 -R '@RG\tID:tumor\tSM:tumor\tPL:ILLUMINA' \
    $REF $DATA/S17.T_R1.fastq.gz $DATA/S17.T_R2.fastq.gz \
    > $BAM/tumor.sam

# === STEP 3: Sort ===
samtools view -bS $BAM/normal.sam | samtools sort - $BAM/normal.sorted
samtools view -bS $BAM/tumor.sam | samtools sort - $BAM/tumor.sorted

# === STEP 4: Mark Duplicates ===
gatk MarkDuplicates \
    -I $BAM/normal.sorted.bam \
    -O $MARKDUP/normal.markdup.bam \
    -M $MARKDUP/normal.metrics.txt

gatk MarkDuplicates \
    -I $BAM/tumor.sorted.bam \
    -O $MARKDUP/tumor.markdup.bam \
    -M $MARKDUP/tumor.metrics.txt

# === STEP 5: Index ===
samtools index $MARKDUP/normal.markdup.bam
samtools index $MARKDUP/tumor.markdup.bam

# === STEP 6: Flagstat (Post-alignment QC) ===
samtools flagstat $MARKDUP/normal.markdup.bam > results/normal.flagstat.txt
samtools flagstat $MARKDUP/tumor.markdup.bam > results/tumor.flagstat.txt

# === STEP 7: Variant Calling ===
gatk Mutect2 \
    -R $REF \
    -I $MARKDUP/tumor.markdup.bam -tumor tumor \
    -I $MARKDUP/normal.markdup.bam -normal normal \
    -O $VCF/somatic.vcf.gz

# === STEP 8: Filter ===
gatk FilterMutectCalls \
    -R $REF \
    -V $VCF/somatic.vcf.gz \
    -O $VCF/somatic.filtered.vcf.gz

# === STEP 9: Annotation ===
# Annotation was performed using Ensembl VEP online tool (https://www.ensembl.org/Tools/VEP)
# Input: somatic.filtered.vcf.gz
# Species: Human, Assembly: GRCh38