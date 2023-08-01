#!/bin/bash
sample=$1
db=$2
conifer_path=$3
savedir=$4

mkdir -p ${savedir}/taxonomy_classification/K2_scores

echo ""
echo "    Obtaining kraken2 confidence scores..."
echo ""


${conifer_path} \
	--input ${savedir}/taxonomy_classification/K2_results/$sample.k2.out \
	--db $db/taxo.k2d \
	--summary \
	--both_scores \
	> ${savedir}/taxonomy_classification/K2_scores/$sample.k2.score

echo ""
echo "    Confidence scores generated!"
echo ""
