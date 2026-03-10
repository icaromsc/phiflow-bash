#Adapted from https://github.com/signalbash/how_are_we_stranded_here

import argparse
import numpy as np
import pandas as pd
import csv
import os
import sys
import subprocess
import binascii
import re
from statistics import median
from statistics import stdev


#Parse arguments from command line 
parser = argparse.ArgumentParser(description='Check if bam files are stranded')
parser.add_argument('-g', '--bed', type=str, help='Genomic regions BED file', required = True)
parser.add_argument('-b', '--bam', type=str, help='.bam file with aligment sequences', required = True)
parser.add_argument('-p', '--print_commands', action='store_true', help='Print bash commands as they occur?')
#parser.add_argument('-s', '--single_end', action='store_true', help='Single-end libraries? Add this option to specify it. Default is paired-end data')
parser.add_argument('library',type=str, help='Library type: single-end or paired-end data',choices=['single-end','paired-end'])

args = parser.parse_args()
    
bed_filename = args.bed
bam_filename = args.bam
print_cmds = args.print_commands
library = args.library
#Check library type choosed
if library == 'single-end':
    single_strand = True
else:
    single_strand = False
    
#single_strand = args.single_end

print(bed_filename)
print(bam_filename)
print(single_strand)
# Global variables for test porpuses
#bed_filename = '/scratch/icaro/genome_indexes/gene_annotation/Homo_sapiens.GRCh38.104.bed'
#bam_filename = '/scratch/icaro/meditation_virus/reads/mapped/SRR14467520_mapped.bam'
#print_cmds = True
#single_strand = True
sample = 'SRR14467520'

# check if dependancies available
def run_command(cmd):
    """given shell command, returns communication tuple of stdout and stderr"""
    cmd_result = subprocess.Popen(cmd, shell = True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE).communicate()
    return(cmd_result)

check_RSeQC = run_command(cmd = 'infer_experiment.py --help')[1] == b''
if not check_RSeQC:
    sys.exit("infer_experiment.py (RSeQC) is not found in PATH. Please install from http://rseqc.sourceforge.net/#installation")

######## MAIN ##########
print('checking strandedness...')
cmd = 'infer_experiment.py -r ' + bed_filename + ' -i ' + bam_filename + ' > ' + sample +'_strandedness_check.txt'
if print_cmds:
    print('running command: ' + cmd)

subprocess.call(cmd, shell=True)

result = pd.read_csv(sample + '_strandedness_check.txt', sep="\r\n", header=None, engine='python')

failed = float(result.iloc[1,0].replace('Fraction of reads failed to determine: ', ''))

if single_strand:
    fwd = float(result.iloc[2,0].replace('Fraction of reads explained by "++,--": ', ''))
    rev = float(result.iloc[3,0].replace('Fraction of reads explained by "+-,-+": ', ''))
else:
    fwd = float(result.iloc[2,0].replace('Fraction of reads explained by "1++,1--,2+-,2-+": ', ''))
    rev = float(result.iloc[3,0].replace('Fraction of reads explained by "1+-,1-+,2++,2--": ', ''))
fwd_percent = fwd/(fwd+rev)
rev_percent = rev/(fwd+rev)

print(result.iloc[0,0])
print(result.iloc[1,0])
print(result.iloc[2,0] + " (" + str(round(fwd_percent*100, 1)) + "% of explainable reads)")
print(result.iloc[3,0] + " (" + str(round(rev_percent*100, 1)) + "% of explainable reads)")


if float(result.iloc[1,0].replace('Fraction of reads failed to determine: ', '')) > 0.50:
    print('Failed to determine strandedness of > 50% of reads.')
    print('If this is unexpected, try running again with a higher --nreads value')
if fwd_percent > 0.9:
    if single_strand:
        print('Over 90% of reads explained by "++,--"')
        print('Data is likely FR/fr-stranded')
    else:
        print('Over 90% of reads explained by "1++,1--,2+-,2-+"')
        print('Data is likely FR/fr-secondstrand')
    print('FeatureCounts parameter will be:\n -s 1')
elif rev_percent > 0.9:
    if single_strand:
        print('Over 90% of reads explained by "+-,-+"')
        print('Data is likely RF/rf-stranded')
    else:
        print('Over 90% of reads explained by "1+-,1-+,2++,2--"')
        print('Data is likely RF/fr-firststrand')
    print('FeatureCounts parameter will be:\n -s 2')
elif max(fwd_percent, rev_percent) < 0.6:
    print('Under 60% of reads explained by one direction')
    print('Data is likely unstranded')
    print('FeatureCounts parameter will be:\n -s 0')
else:
    print('Data does not fall into a likely stranded (max percent explained > 0.9) or unstranded layout (max percent explained < 0.6)')
    print('Please check your data for low quality and contaminating reads before proceeding')
