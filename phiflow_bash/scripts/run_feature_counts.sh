#!/bin/bash
threads=16
sample=$1
strandness=$2
ref_annotation=$3
workdir=$4
savedir=$5
paired_end=$6

#create output folders to save files if not exist
mkdir -p ${savedir}/genecounts/

#Obtain strandness parameter
tag=$( tail -n 2 ${savedir}/strandness_result.txt | head -n 1)
#Show parameter
cat ${savedir}/strandness_result.txt | tail -n 3
echo "    Counting genes with featureCounts..."
if [ $paired_end == "yes" ];
then
	featureCounts -T $threads \
		$tag \
		-a ${ref_annotation} \
		-p \
		-o ${savedir}/genecounts/${sample}_featurecounts.txt \
		${savedir}/mapping/mapped/${sample}_Aligned.out.bam
else
	featureCounts -T $threads \
		$tag \
		-a ${ref_annotation} \
		-o ${savedir}/genecounts/${sample}_featurecounts.txt \
		${savedir}/mapping/mapped/${sample}_Aligned.out.bam
fi
echo "    Counting finished!"
