// Define input parameter
params.sraID = ""

// Define the Docker images for each tool
docker {
    "quay.io/biocontainers/sra-tools:2.10.8--pl526h8f50634_2"
    "quay.io/biocontainers/fastp:0.20.1--hdfd78af_1"
    "quay.io/biocontainers/star:2.7.8a--h10a08f0_2"
    "quay.io/biocontainers/subread:2.0.1--he1b5a44_0"
    "quay.io/biocontainers/multiqc:1.11--pyh9f0ad1d_0"
}

// Define the channel for the SRA ID
sraChannel = Channel.from([params.sraID])

// Define the pipeline
process download {
    output:
    file("{params.sraID}.fastq.gz")

    script:
    """
    fasterq-dump --outdir . --gzip --skip-technical --readids --read-filter pass --dumpbase --split-files ${params.sraID}
    """
    container "quay.io/biocontainers/sra-tools:2.10.8--pl526h8f50634_2"
}

process fastp {
    input:
    file(reads) from sraChannel
    output:
    file("${reads.baseName}_filtered.fastq.gz")

    script:
    """
    fastp -i ${reads} -o ${output} --qualified_quality_phred 20 --thread 2
    """
    container "quay.io/biocontainers/fastp:0.20.1--hdfd78af_1"
}

process star {
    input:
    file(reads) from sraChannel
    file(filteredReads) from fastp.out
    output:
    file("${reads.baseName}.bam")

    script:
    """
    STAR --genomeDir /path/to/human_reference_genome --readFilesIn ${filteredReads} --outFileNamePrefix ${reads.baseName} --outSAMtype BAM SortedByCoordinate --runThreadN 2
    """
    container "quay.io/biocontainers/star:2.7.8a--h10a08f0_2"
}

process featureCounts {
    input:
    file(bam) from star.out
    output:
    file("${bam.baseName}.counts")

    script:
    """
    featureCounts -T 2 -a /path/to/gene_annotation_file.gtf -o ${output} ${bam}
    """
    container "quay.io/biocontainers/subread:2.0.1--he1b5a44_0"
}

process multiqc {
    input:
    file("*_fastp.html"), file("*Log.final.out"), file("*_counts")

    output:
    file("multiqc_report.html")

    script:
    """
    multiqc .
    """
    container "quay.io/biocontainers/multiqc:1.11--pyh9f0ad1d_0"
}

// Define the pipeline
download | fastp | star | featureCounts | multiqc
