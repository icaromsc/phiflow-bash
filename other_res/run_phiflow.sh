#!/bin/bash

# SHOW WELCOME MESSAGE

cat << "EOF"
██████╗░██╗░░██╗██╗███████╗██╗░░░░░░█████╗░░██╗░░░░░░░██╗
██╔══██╗██║░░██║██║██╔════╝██║░░░░░██╔══██╗░██║░░██╗░░██║
██████╔╝███████║██║█████╗░░██║░░░░░██║░░██║░╚██╗████╗██╔╝
██╔═══╝░██╔══██║██║██╔══╝░░██║░░░░░██║░░██║░░████╔═████║░
██║░░░░░██║░░██║██║██║░░░░░███████╗╚█████╔╝░░╚██╔╝░╚██╔╝░
╚═╝░░░░░╚═╝░░╚═╝╚═╝╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░╚═╝░░

██████╗░██╗██████╗░███████╗██╗░░░░░██╗███╗░░██╗███████╗
██╔══██╗██║██╔══██╗██╔════╝██║░░░░░██║████╗░██║██╔════╝
██████╔╝██║██████╔╝█████╗░░██║░░░░░██║██╔██╗██║█████╗░░
██╔═══╝░██║██╔═══╝░██╔══╝░░██║░░░░░██║██║╚████║██╔══╝░░
██║░░░░░██║██║░░░░░███████╗███████╗██║██║░╚███║███████╗
╚═╝░░░░░╚═╝╚═╝░░░░░╚══════╝╚══════╝╚═╝╚═╝░░╚══╝╚══════╝
EOF

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

## LOADING MODULES FROM CONFIG FILE ######## 
eval $(parse_yaml config_test.yaml)

echo "dataset_name:" $dataset_name
echo "module_execution:" $module_execution_type
echo "paired-end data?" $paired_end
echo "library strandness:" $strandness
echo "working directory:" $workdir
echo "samples directory:" $samplesdir
echo "sra_accesion_list_path:" $sample_ids_file
echo "host_genome_annotation_path_gtf:" $host_genome_annotation_path_gtf
echo "host_genome_annotation_path_bed:" $host_genome_annotation_path_bed
echo "host_genome_index:" $host_genome_index_path
echo "kraken2_db_path:" $kraken2_db_path
echo "conifer_path:" $conifer_path
echo ""

### CREATE WORKDIR RESULTS FOLDER
workdir_results="${workdir}/results/${dataset_name}"
#echo "creating results folder:" ${workdir_results}
mkdir -p ${workdir_results}
echo ""


########### PROCESS SAMPLES IF EXIST #############
echo "Starting pipeline..."
while IFS= read -r sample; do
    cat << "EOF"
    
⠾⠿⠿⠿⡿⢷⣶⣀⠀⠀⢀⣰⡾⣿⠿⠿⢿⣶⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣾⠿⠃
⠀⢸⡇⢸⡇⢰⡎⠙⠷⣤⡛⣵⠀⣿⠀⣿⢠⡮⢙⡷⣤⡀⠀⠀⠀⠀⠀⠀⠀⣠⡾⢻⡆⠀⠀
⠀⢸⡇⢸⡇⠸⣇⣴⠆⠈⢻⣝⠀⣿⠀⣿⢸⡗⢸⡇⠈⠻⣄⠀⠀⠀⠀⣠⡾⢛⣷⢸⡇⠀⠀
⠀⢸⡇⠸⡷⢰⡿⠃⠀⠀⠀⠻⣷⡛⠀⣿⢸⡷⢸⡇⢸⡇⠻⣷⡀⠀⣾⠟⣿⢘⣿⢸⡇⠀⠀
⠀⠸⠇⣠⡶⠋⠀⠀⠀⠀⠀⠀⠈⠻⣦⡛⢸⣇⢸⡇⢸⡇⢸⣏⡻⣦⡀⠀⣿⢸⣟⢸⡇⠀⠀
⣠⣴⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠷⣦⣬⣃⣸⣥⡶⠟⠁⠈⠙⠷⣯⣬⣏⣘⣣⣤⠄
⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠛⠃⠀⠀
EOF
    date
    echo "Processing sample $sample..."
    bash scripts/run_fastp.sh $sample $paired_end $samplesdir $workdir_results
    bash scripts/run_star.sh $sample $paired_end $host_genome_index_path $workdir_results
    bash scripts/run_check_strandness.sh $sample $paired_end $host_genome_annotation_path_bed $workdir $workdir_results
    bash scripts/run_feature_counts.sh $sample $strandness $host_genome_annotation_path_gtf $workdir $workdir_results $paired_end
    bash scripts/run_kraken2.sh $sample $paired_end $kraken2_db_path $workdir_results
    bash scripts/obtain_kraken2_scores.sh $sample $kraken2_db_path $workdir_results
    bash scripts/clean_files.sh ${sample} $paired_end $workdir_results
    echo "$sample processing finished!"
done < "$sample_ids_file"

echo "generating data matrices..."
Rscript --vanilla scripts/join_kraken_plus_confidence_reports.R ${workdir_results}/taxonomy_classification

cat << "EOF"

⠀⠀⠀⢰⣆⣀⣼⣃⠀⣴⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠶⣤⣾⣿⡿⣿⣿⣿⣧⡀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣠⣠⣿⣿⣳⢿⣽⢾⣿⣿⣿⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠹⣿⡷⣯⢿⣞⣿⣻⣿⣿⣞⠃⠀⠀⠀⣀⣄⡀⠀⠀⠀⢀⣀⡀⠀
⠐⠞⠛⢿⣯⡿⣞⣷⢯⣿⣿⣿⣷⠞⠃⠰⣏⠌⠻⣦⡀⢰⣏⠍⣿⡆
⠀⠀⠐⠛⣿⣿⡽⣾⣻⢾⣿⣿⣿⡷⠶⠀⠹⣮⣅⡘⡙⠛⢿⣄⠓⡿
⠀⠀⠀⣤⠿⣿⣽⣳⣿⣿⣿⣿⡿⢤⡄⠀⠀⠀⠙⠳⠯⠝⣼⠇⡏⣶
⠀⠀⠀⠀⢠⡟⠻⣿⠿⢿⡟⠻⣄⠀⠀⣴⡶⣦⡀⠀⣀⣴⢏⡼⣸⠏
⠀⣀⣤⣤⣤⡀⠠⠟⠀⠘⠇⠀⠉⠀⢸⡇⡞⣾⠁⣾⣋⠴⣣⡾⠋⠀
⣼⠋⡀⠄⠨⠻⣦⣀⡀⠀⠀⠀⠀⠀⠸⣇⣚⢻⣆⡙⠛⠛⠉⠀⠀⠀
⢻⣥⡐⡈⠄⠂⠄⠉⠛⠛⠻⣦⡀⠀⠀⠹⣦⡌⢪⢿⡆⠀⠀⠀⠀⠀
⠀⠙⢠⣅⠓⠎⠤⠥⠌⣤⠱⣈⣷⣀⠀⠀⠈⠙⠳⠛⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠉⠻⠾⣴⣅⣊⣄⣲⣾⣏⡉⠛⠶⣤⣤⠶⠞⠂⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠁⠀⠈⠙⠛⠶⢦⣽⣷⣤⣄⣀⣀⣀⡀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣦⠉⠉⠉⠉⠁

EOF

echo "All samples were processed!"
