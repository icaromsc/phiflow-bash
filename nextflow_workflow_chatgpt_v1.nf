// Define input parameter
params.sraID = ""

// Define the Docker images for each tool
docker {
    image 'ncbi/sra-tools'
    image 'weizhongli/fastp'
    image 'alexdobin/star'
    image 'biocontainers/subread:2.0.0'
}

// Define the process to download the sample from SRA database
process download {
    output:
    file("${params.sraID}.fastq.gz") into raw_reads

    script:
    """
    fasterq-dump --outdir . --gzip --skip-technical --readids --read-filter pass --dumpbase --split-files ${params.sraID}
    """
}

// Define the process to perform quality control using fastp
process fastp {
    input:
    file(reads) from raw_reads
    output:
    file("${reads.baseName}_filtered.fastq.gz") into filtered_reads

    script:
    """
    fastp -i ${reads} -o ${reads.baseName}_filtered.fastq.gz --qualified_quality_phred 20 --thread 2
    """
}

// Define the process to perform read mapping using STAR
process star {
    input:
    file(reads) from filtered_reads
    output:
    file("${reads.baseName}.bam") into alignment

    script:
    """
    STAR --genomeDir /path/to/human_reference_genome --readFilesIn ${reads} --outFileNamePrefix ${reads.baseName} --outSAMtype BAM SortedByCoordinate --runThreadN 2
    """
}

// Define the process to perform feature counting using featureCounts
process featureCounts {
    input:
    file(bam) from alignment
    output:
    file("${bam.baseName}.counts") into gene_counts

    script:
    """
    featureCounts -T 2 -a /path/to/gene_annotation_file.gtf -o ${bam.baseName}.counts ${bam}
    """
}

// Define the pipeline
workflow {
    download | fastp | star | featureCounts
}
