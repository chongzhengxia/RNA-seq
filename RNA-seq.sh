##step1 Raw data is processed using fastp
------------------------------
#!/bin/bash
#SBATCH -p debug
#SBATCH -J fastp
#SBATCH -N 1
#SBATCH -n 16
#SBATCH -o fastp.o
#SBATCH -e fastp.e
cd /PUBLIC/home/xiachongzheng/RNA-seq/01_rawdata/data
for i in $(ls -d  H9*)
do
        mkdir /PUBLIC/home/xiachongzheng/RNA-seq/02_cleandata/${i}
        cd /PUBLIC/home/xiachongzheng/RNA-seq/01_rawdata/data/${i}
        fastp -w 16 -i ${i}_1.fq.gz -I ${i}_2.fq.gz -o /PUBLIC/home/xiachongzheng/RNA-seq/02_cleandata/${i}/${i}_1.fq.gz -O /PUBLIC/home/xiachongzheng/RNA-seq/02_cleandata/${i}/${i}_2.fq.gz
done

------------------------------

##step2 Use STAR to align QC data to a reference genome
------------------------------
#!/bin/bash
#SBATCH -p common
#SBATCH -J STAR
#SBATCH -N 2
#SBATCH -n 104
#SBATCH -o STAR.o
#SBATCH -e STAR.e
cd /PUBLIC/home/xiachongzheng/RNA-seq/02_cleandata
ls -al | awk '$9~/^H9/{print $9}' | while read dirname
do
        cd /PUBLIC/home/xiachongzheng/RNA-seq/02_cleandata/${dirname}
        STAR --runThreadN 104 --genomeDir /PUBLIC/home/xiachongzheng/RNA-seq/00_ref/ucsc/STAR_hg38_index/ \
        --outSAMtype BAM Unsorted \
        --runMode alignReads \
        --readFilesCommand zcat \
        --readFilesIn *_1* *_2* \
        --outFileNamePrefix /PUBLIC/home/xiachongzheng/RNA-seq/03_STAR_align_out/${dirname} \
        --quantMode TranscriptomeSAM GeneCounts
done
------------------------------

##step3 Quantification was performed using RSEM
------------------------------
#SBATCH -p common
#SBATCH -J rsem
#SBATCH -N 2
#SBATCH -n 104
#SBATCH -o rsem.o
#SBATCH -e rsem.e
cd /PUBLIC/home/xiachongzheng/RNA-seq/03_STAR_align_out
ls -al | awk '$9~/toTranscriptome.out.bam/{print $9}' | while read filename
do
        rsem-calculate-expression --paired-end --no-bam-output  --alignments -p 104 ${filename}  /PUBLIC/home/xiachongzheng/RNA-seq/00_ref/ucsc/rsem_hg38_index/hg38_rsem  \
        /PUBLIC/home/xiachongzheng/RNA-seq/04_rsem_out/${filename%Aligned.toTranscriptome.out.bam}
done
------------------------------
















