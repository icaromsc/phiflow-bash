sample=$1
#sample="SRR1656571"
filepath="K2_results"
db="/scratch/kraken2db/k2_pluspf/taxo.k2d"

/scratch/icaro/Conifer/conifer \
	--input $filepath/$sample.k2.out \
	--db $db \
	--summary \
	--both_scores \
	> $sample.k2.score
