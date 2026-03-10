dataset_name="test_results"
host_genome_annotation_path_gtf="/home/icastro/human_reference/T2T/GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf"
sample="SRR1026908"
strandness="auto"
workdir="/home/icastro/workspace/phiflow-bash/phiflow_bash"
workdir_results="${workdir}/results/${dataset_name}"
paired_end="yes"
bash -x scripts/run_feature_counts.sh $sample $strandness $host_genome_annotation_path_gtf $workdir $workdir_results $paired_end
