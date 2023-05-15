#!/bin/bash

echo "Starting pipeline processing list samples:"
while IFS= read -r line; do
    date
    echo "processing sample $line"
    bash run_fastp_PE.sh $line
    bash run_star_PE.sh $line
    bash run_kraken2_SE.sh $line
    bash obtain_kraken2_scores.sh $line
    echo "$line processing finished!"
done < "$1"
echo "all samples were processed!"
