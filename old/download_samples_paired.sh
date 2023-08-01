#!/bin/bash
echo "Starting download of SRA list samples:"
while IFS= read -r line; do
    echo "downloading $line"
    fastq-dump --gzip $line --split-3
    echo "$line fastq download finished"
done < "$1"
echo "all samples were downloaded"
echo "script finished!"
