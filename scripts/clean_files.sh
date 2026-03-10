sample=$1
paired_end=$2
savedir=$3

#Check if pipeline end files exist
if [[ -f "${savedir}/genecounts/${sample}_featurecounts.txt" ]] && [[ -f "${savedir}/taxonomy_classification/K2_results/${sample}.k2.report" ]];
then	
	echo ""
	echo "    Deleting temporary files..."
	echo ""

	rm ${savedir}/mapping/mapped/${sample}_Aligned.out.bam
	rm ${savedir}/qc/${sample}_*.fastq.gz
	rm ${savedir}/taxonomy_classification/K2_results/${sample}.k2.out
else
	# Do not delete files
	echo ""
	echo "    Expected files doesn't exist!"
	echo "    Some error ocurred!"
	echo "    Skipping deletion step..."
	echo ""

fi
