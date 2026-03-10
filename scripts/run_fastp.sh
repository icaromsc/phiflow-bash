#!/bin/bash
thread=16
sample=$1
paired_end=$2
samples_dir=$3
savedir=$4
echo ""
echo "    QC Filtering..."
echo ""
#create folder to save files if not exist
savedir="${savedir}/qc"
#echo "creating fastp output folder:" ${savedir}
mkdir -p ${savedir}

if [ $paired_end == "yes" ];
then
	#echo "paired end data"
	fastp \
		--in1 ${samples_dir}/${sample}_R1.fastq.gz \
		--in2 ${samples_dir}/${sample}_R2.fastq.gz \
		--out1 ${savedir}/${sample}_R1_filtered.fastq.gz \
		--out2 ${savedir}/${sample}_R2_filtered.fastq.gz \
		--average_qual 30 \
		--json ${savedir}/${sample}_fastp.json \
		--html ${savedir}/${sample}_fastp.html \
		--thread $thread
	
else
	#echo "single end data"
	fastp \
		--in1 ${samples_dir}/${sample}.fastq.gz \
		--out1 ${savedir}/${sample}_filtered.fastq.gz \
		--average_qual 30 \
		--json ${savedir}/${sample}_fastp.json \
		--html ${savedir}/${sample}_fastp.html \
		--thread $thread
fi
#Run fastp
#fastp \
#	--in1 ${sample}_R1_001.fastq.gz \
#	--in2 ${sample}_R2_001.fastq.gz \
#	--out1 ${sample}_R1_001_filtered.fastq.gz \
#	--out2 ${sample}_R2_001_filtered.fastq.gz \
#	-e 30 \
#	--json ${sample}_fastp.json \
#	--html ${sample}_fastp.html \
#	--thread $thread

#Delete raw data after processing...
#if [ -f "${sample}_trim_R1.fastq.gz" ]; then
#    echo "deleting raw files..."
#    rm ${sample}_1.fastq.gz
#    rm ${sample}_2.fastq.gz
#else
#    echo "not deleting raw files..."
#fi

echo "    QC filtering finished!"
echo ""
