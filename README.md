# PHIFlow-Bash

**PHIFlow-Bash** is a modular bash-based pipeline for host--microbe
transcriptomic profiling from RNA-seq data.\
It integrates host alignment, gene quantification, microbial
classification and detection into a unified workflow.


------------------------------------------------------------------------
# Workflow scheme
![phiflow Overview](docs/images/workflow_pipeline_2023_updated.png)

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Read QC ([`fastp`](https://github.com/OpenGene/fastp))
2. Read alignment to the human host genome ([`STAR`](https://github.com/alexdobin/STAR))
3. Infer library strandedness ([`RSeQC`](https://rseqc.sourceforge.net/))
4. Quantify host gene expression ([`subread:featureCounts`](https://github.com/ShiLab-Bioinformatics/subread))
5. Taxonomic profiling of host unmapped reads ([`Kraken2`](https://ccb.jhu.edu/software/kraken2/))
6. Calculate confidence scores from Kraken2 taxonomic profiling ([`Conifer`](https://github.com/ivarz/conifer))
7. Present summary of all previous processing steps ([`MultiQC`](http://multiqc.info/))


# ⚠️ Prerequisites

Before running the pipeline, the required reference resources must be
prepared.

------------------------------------------------------------------------

## 1️⃣ Human Reference Genome and STAR Index

PHIFlow requires:

-   Human genome FASTA (e.g., GRCh38)
-   Gene annotation file (GTF)
-   STAR genome index

Reference genome and GTF files can be obtained from:

https://www.ensembl.org

Generate the genome index using STAR:

``` bash
STAR \
  --runThreadN 16 \
  --runMode genomeGenerate \
  --genomeDir /path/to/star_index/ \
  --genomeFastaFiles Homo_sapiens.GRCh38.dna.primary_assembly.fa \
  --sjdbGTFfile Homo_sapiens.GRCh38.gtf \
  --sjdbOverhang 100
```

Provide the paths in the configuration file:

``` yaml
host_genome_index_path: "/path/to/star_index/"
host_genome_annotation_path_gtf: "/path/to/Homo_sapiens.GRCh38.gtf"
```

A BED annotation file is also required for RSeQC.

------------------------------------------------------------------------

## 2️⃣ Kraken2 Database

Microbial classification requires a pre-built database for Kraken2.

Official databases are available at:

-   https://ccb.jhu.edu/software/kraken2/
-   https://benlangmead.github.io/aws-indexes/k2

### ✅ Recommended: PlusPF

We recommend using the **PlusPF** database\
(*Standard + Protozoa and Fungi*), which provides broad microbial
coverage suitable for host--microbe transcriptomic studies.

After downloading the database, define its path in the configuration
file:

``` yaml
kraken2_db_path: "/path/to/kraken2_db"
```

------------------------------------------------------------------------

# 💻 Hardware Requirements

## 🧠 Memory (RAM)

-   STAR alignment (GRCh38 index): \~30--35 GB RAM\
-   Kraken2 loads the **entire database into RAM**

RAM usage for Kraken2 is proportional to database size.

For the PlusPF database:

-   \~100--150 GB RAM required

### Recommended minimum:

-   **128 GB RAM** for full pipeline execution with PlusPF

------------------------------------------------------------------------

## 💾 Disk Space

  Resource              Approximate Size
  --------------------- ---------------------
  STAR index (GRCh38)   \~30--35 GB
  Kraken2 PlusPF        \~100--150 GB
  BAM files             5--15 GB per sample

Minimum recommended free space:

-   200 GB (small projects)\
-   500+ GB (medium/large cohorts)

------------------------------------------------------------------------

# 🧬 Software Environment

Create the Conda environment:

``` bash
mamba env create -f environment.yml
conda activate phiflow-bash
```

------------------------------------------------------------------------

# 🚀 Running the Pipeline

Execution requires a single command:

``` bash
bash run_phiflow.sh config_profile.yml
```

------------------------------------------------------------------------

# ⚙️ Configuration File

The pipeline is controlled by a YAML configuration file.

Example:

``` yaml
module_execution_type: "both"
sample_ids_file: "/scratch/icaro/phiflow_pipeline/sepsis_samples.txt"
dataset_name: "GSE154918"
kraken2_db_path: "/scratch/kraken2db/k2_pluspf"
host_genome_index_path: "/scratch/icaro/genome_indexes/index/100/"
host_genome_annotation_path_gtf: "/scratch/icaro/genome_indexes/gene_annotation/Homo_sapiens.GRCh38.104.gtf"
host_genome_annotation_path_bed: "/scratch/icaro/genome_indexes/gene_annotation/Homo_sapiens.GRCh38.104.bed"
conifer_path: "/scratch/icaro/Conifer/conifer"
paired_end: "yes"
strandness: "auto"
workdir: "/scratch/icaro/phiflow_pipeline"
samplesdir: "/home/CSBL/icaro/sandbox/metatranscriptomics/studies/GSE154918"
```

------------------------------------------------------------------------

# 🔎 Parameter Description

  |Parameter | Description |
  | --- |--- |
  | module_execution_type: | "host", "microbe", or "both" (default) |
  |sample_ids_file: | File containing sample IDs (one per line) |
  | dataset_name: | Dataset name used as output folder |
  | kraken2_db_path: | Path to Kraken2 database |
  | host_genome_index_path: | STAR genome index directory |
  | host_genome_annotation_path_gtf: | GTF annotation filepath |
  | host_genome_annotation_path_bed: | BED annotation filepath |
  | conifer_path | Path to CONIFER executable |
  | paired_end: | "yes" or "no" |
  | strandness | "auto", "yes", or "no" |
  | workdir | Output directory |
  | samplesdir | Directory containing FASTQ files |

------------------------------------------------------------------------

# 📂 Expected Input

FASTQ files must be located in the directory specified by:

`samplesdir`

### Paired-end format:

    sample1_R1.fastq.gz
    sample1_R2.fastq.gz

### Single-end format:

    sample1.fastq.gz

------------------------------------------------------------------------

# 📊 Output

All results are generated inside the directory specified in:

`workdir/`

Outputs include:

-   BAM alignment files\
-   Gene count matrices\
-   Kraken2 classification reports\
-   MultiQC summary report

------------------------------------------------------------------------

