#!/bin/bash
thread=24
sample=$1
paired_end=$2
database=$3
savedir=$4
echo ""
echo "    Running taxonomy classification of unmapped reads..."
echo ""

#create folder to save files if not exist"
#echo "creating kraken output folder:" ${savedir}
#echo "saving at: "${savedir}
mkdir -p ${savedir}/taxonomy_classification/K2_results/


if [ $paired_end == "yes" ];
then
	#echo "paired end data"
	conda run -p /mnt/storwize/opt2/miniconda3/envs/kraken2 kraken2 \
		--report-minimizer \
		--threads $thread \
		--db $database \
		${savedir}/mapping/unmapped/${sample}_Unmapped.out.mate1.gz \
		${savedir}/mapping/unmapped/${sample}_Unmapped.out.mate2.gz \
		--output ${savedir}/taxonomy_classification/K2_results/$sample.k2.out \
		--report ${savedir}/taxonomy_classification/K2_results/$sample.k2.report \
		--use-names \
		--gzip-compressed \
		--paired \
		--confidence 0.0
else
	#echo "single end data"
	conda run -p /mnt/storwize/opt2/miniconda3/envs/kraken2 kraken2 \
		--report-minimizer \
		--threads $thread \
		--db $database \
		${savedir}/mapping/unmapped/${sample}_Unmapped.out.mate1.gz \
		--output ${savedir}/taxonomy_classification/K2_results/$sample.k2.out \
		--report ${savedir}/taxonomy_classification/K2_results/$sample.k2.report \
		--use-names \
		--gzip-compressed \
		--confidence 0.0
fi
echo ""
echo "    Kraken2-Uniq classification finished!";
echo ""
