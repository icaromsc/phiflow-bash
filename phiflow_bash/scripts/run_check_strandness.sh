#!/bin/bash
threads=16
sample=$1
paired_end=$2
ref_annotation=$3
workdir=$4
savedir=$5

if [ -f "${savedir}/strandness_result.txt" ]; then
    echo ""
    echo "    Strandness already checked..."
    echo "    Skipping step..."
    echo ""
else
    echo ""
    echo "    Checking library strandness..."
    echo ""
    ##commands
    if [ $paired_end == "yes" ];then
	#Command call
	conda run -p /mnt/storwize/opt2/miniconda3/envs/rseqc python ${workdir}/scripts/check_strandness.py \
	       --bed ${ref_annotation} \
	       --bam ${savedir}/mapping/mapped/${sample}_Aligned.out.bam \
	       paired-end > ${savedir}/strandness_result.txt	       
    else
    	#Command call
	conda run -p /mnt/storwize/opt2/miniconda3/envs/rseqc python ${workdir}/scripts/check_strandness.py \
	       --bed ${ref_annotation} \
	       --bam ${savedir}/mapping/mapped/${sample}_Aligned.out.bam \
	       single-end > ${savedir}/strandness_result.txt
    fi
    echo "    Check strandness complete!"    
fi

