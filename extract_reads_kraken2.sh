#!/bin/bash

#Declare a string array
#TaxonIds=(4909 4952 5478 42374 273371 5476 37769 4932 5810 4896)


echo "processing list of taxon IDs:"
while IFS= read -r line; do
    echo "extracting kraken2 classified reads for taxon id: $line"
    python ../KrakenTools/extract_kraken_reads.py -k SRR8536145.k2.out -t $line -s1 SRR8536145_1.fastq.gz -s2 SRR8536145_2.fastq.gz -o SRR8536145_1.$line.fastq -o2 SRR8536145_2.$line.fastq --include-children -r SRR8536145.k2.report
    echo "$line extraction finished"
done < "$1"

