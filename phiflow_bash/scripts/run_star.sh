#!/bin/bash
threads=16
sample=$1
paired_end=$2
ref_index=$3
savedir=$4
echo ""
echo "    Mapping reads against human genome..."
echo ""

#create output folders to save files if not exist
mkdir -p ${savedir}/mapping
if [ $paired_end == "yes" ];
then
	#Command call index 100 with 0.66 score alignment
	conda run -p /mnt/storwize/opt2/miniconda3/envs/star STAR \
		--runMode alignReads \
		--runThreadN $threads \
		--outSAMtype BAM Unsorted \
		--readFilesCommand zcat \
		--genomeDir $ref_index  \
		--outReadsUnmapped Fastx \
		--outFileNamePrefix $savedir/mapping/${sample}_ \
		--readFilesIn ${savedir}/qc/${sample}_R1_filtered.fastq.gz ${savedir}/qc/${sample}_R2_filtered.fastq.gz
	gzip ${savedir}/mapping/${sample}_Unmapped.out.mate*
else
	conda run -p /mnt/storwize/opt2/miniconda3/envs/star STAR \
		--runMode alignReads \
		--runThreadN $threads \
		--outSAMtype BAM Unsorted \
		--readFilesCommand zcat \
		--genomeDir $ref_index  \
		--outReadsUnmapped Fastx \
		--outFileNamePrefix $savedir/mapping/${sample}_ \
		--readFilesIn ${savedir}/qc/${sample}_filtered.fastq.gz

	gzip ${savedir}/mapping/${sample}_Unmapped.out.mate1
fi

echo "    mapping finished!"

echo "    Saving mapped and unmmaped reads..."
mkdir -p ${savedir}/mapping/mapped
mkdir -p ${savedir}/mapping/unmapped
mv ${savedir}/mapping/*.out.mate* ${savedir}/mapping/unmapped/
mv ${savedir}/mapping/*.out* ${savedir}/mapping/mapped/

#Ranaming & Compressing unmapped reads
#mv ${sample}_Unmapped.out.mate1 ${sample}_unmapped.fastq
#gzip ${sample}_unmapped.fastq

#Deleting trim data after mapping
#if [ -f "${sample}_Aligned.out.bam" ]; then
#    echo "deleting trimmed reads after mapping..."
#    rm ${sample}_trim_R*.fastq.gz
#else
#    echo "not delete trimmed reads..."
#fi
