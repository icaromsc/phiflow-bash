

usage: python check_strandness.py -g/--bed myfile.bed, -b/--bam myfile.bam , library[paired-end,single-end]

Example:

#Paired-end usage:

python check_strandness.py \
	--bed /scratch/icaro/genome_indexes/gene_annotation/Homo_sapiens.GRCh38.104.bed \
	--bam /scratch/icaro/dermatitis_dataset/raw/25FCS_S1_L002_Aligned.out.bam \
	paired-end

#Single-end usage:

python check_strandness.py \
	--bed /scratch/icaro/genome_indexes/gene_annotation/Homo_sapiens.GRCh38.104.bed \
	--bam /scratch/icaro/meditation_virus/reads/mapped/SRR14467518_mapped.bam \
	single-end