#!/bin/bash


# SHOW WELCOME MESSAGE

cat << "EOF"
██████╗ ██╗  ██╗██╗███████╗██╗      ██████╗ ██╗    ██╗      ██████╗  █████╗ ███████╗██╗  ██╗
██╔══██╗██║  ██║██║██╔════╝██║     ██╔═══██╗██║    ██║      ██╔══██╗██╔══██╗██╔════╝██║  ██║
██████╔╝███████║██║█████╗  ██║     ██║   ██║██║ █╗ ██║█████╗██████╔╝███████║███████╗███████║
██╔═══╝ ██╔══██║██║██╔══╝  ██║     ██║   ██║██║███╗██║╚════╝██╔══██╗██╔══██║╚════██║██╔══██║
██║     ██║  ██║██║██║     ███████╗╚██████╔╝╚███╔███╔╝      ██████╔╝██║  ██║███████║██║  ██║
╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝       ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
EOF

# 1. HELP / USAGE FUNCTION
usage() {
    cat << EOF
################################################################################
PHIFlow-Bash: Host-Microbe Profiling Pipeline
################################################################################
Description:
  PHIFlow-Bash is a bioinformatics pipeline written in bash for host-microbe profiling 
  from RNA-seq data. It integrates host alignment, gene quantification, 
  microbial classification and detection into a unified workflow.

Contact:
  icaromscastro@gmail.com

Usage: 
  $0 <config_file.yaml>

Options:
  -h, --help           Show this help message and exit.
################################################################################
EOF
    exit 1
}

# 2. INPUT VALIDATION
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
fi

CONFIG_FILE=$1

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found."
    exit 1
fi

# 3. YAML PARSER FUNCTION
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

# 4. LOAD AND PRINT ALL PARAMETERS
eval $(parse_yaml "$CONFIG_FILE")

echo "--- Loaded Configuration Parameters ---"
# This displays the variables currently in the environment loaded from the YAML
echo "dataset_name:                    $dataset_name"
echo "module_execution_type:           $module_execution_type"
echo "paired_end:                      $paired_end"
echo "strandness:                      $strandness"
echo "workdir:                         $workdir"
echo "samplesdir:                      $samplesdir"
echo "sample_ids_file:                 $sample_ids_file"
echo "host_genome_annotation_path_gtf: $host_genome_annotation_path_gtf"
echo "host_genome_annotation_path_bed: $host_genome_annotation_path_bed"
echo "host_genome_index_path:          $host_genome_index_path"
echo "kraken2_db_path:                 $kraken2_db_path"
echo "conifer_path:                    $conifer_path"
echo "----------------------------------------"
echo ""

# 5. PRE-FLIGHT FILE/DIR EXISTENCE CHECKS
echo "Validating paths..."
MISSING_DATA=0

# Array of paths to check
PATHS_TO_CHECK=(
    "$workdir"
    "$samplesdir"
    "$sample_ids_file"
    "$host_genome_annotation_path_gtf"
    "$host_genome_annotation_path_bed"
    "$host_genome_index_path"
    "$kraken2_db_path"
)

for path in "${PATHS_TO_CHECK[@]}"; do
    if [[ ! -e "$path" ]]; then
        echo " [!] CRITICAL: Path not found: $path"
        MISSING_DATA=1
    fi
done

if [[ $MISSING_DATA -eq 1 ]]; then
    echo "Error: One or more required files/directories are missing. Aborting."
    exit 1
fi
echo "All paths validated successfully."
echo ""

# 6. EXECUTION BLOCK
workdir_results="${workdir}/results/${dataset_name}"
mkdir -p "${workdir_results}"



echo "Starting pipeline..."
while IFS= read -r sample || [[ -n "$sample" ]]; do
    [[ -z "$sample" ]] && continue 
    cat << "EOF"
    
⠾⠿⠿⠿⡿⢷⣶⣀⠀⠀⢀⣰⡾⣿⠿⠿⢿⣶⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣾⠿⠃
⠀⢸⡇⢸⡇⢰⡎⠙⠷⣤⡛⣵⠀⣿⠀⣿⢠⡮⢙⡷⣤⡀⠀⠀⠀⠀⠀⠀⠀⣠⡾⢻⡆⠀⠀
⠀⢸⡇⢸⡇⠸⣇⣴⠆⠈⢻⣝⠀⣿⠀⣿⢸⡗⢸⡇⠈⠻⣄⠀⠀⠀⠀⣠⡾⢛⣷⢸⡇⠀⠀
⠀⢸⡇⠸⡷⢰⡿⠃⠀⠀⠀⠻⣷⡛⠀⣿⢸⡷⢸⡇⢸⡇⠻⣷⡀⠀⣾⠟⣿⢘⣿⢸⡇⠀⠀
⠀⠸⠇⣠⡶⠋⠀⠀⠀⠀⠀⠀⠈⠻⣦⡛⢸⣇⢸⡇⢸⡇⢸⣏⡻⣦⡀⠀⣿⢸⣟⢸⡇⠀⠀
⣠⣴⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠷⣦⣬⣃⣸⣥⡶⠟⠁⠈⠙⠷⣯⣬⣏⣘⣣⣤⠄
⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠛⠃⠀⠀
EOF
    echo "-------------------------------------------------------"
    date
    echo "Processing sample: $sample"
    
    bash scripts/run_fastp.sh "$sample" "$paired_end" "$samplesdir" "$workdir_results"
    bash scripts/run_star.sh "$sample" "$paired_end" "$host_genome_index_path" "$workdir_results"
    bash scripts/run_check_strandness.sh "$sample" "$paired_end" "$host_genome_annotation_path_bed" "$workdir" "$workdir_results"
    bash scripts/run_feature_counts.sh "$sample" "$strandness" "$host_genome_annotation_path_gtf" "$workdir" "$workdir_results" "$paired_end"
    bash scripts/run_kraken2.sh "$sample" "$paired_end" "$kraken2_db_path" "$workdir_results"
    bash scripts/obtain_kraken2_scores.sh "$sample" "$kraken2_db_path" "$workdir_results"
    bash scripts/clean_files.sh "$sample" "$paired_end" "$workdir_results"
    
    echo "$sample processing finished!"
done < "$sample_ids_file"

echo "Generating microbial data matrices..."
Rscript --vanilla scripts/join_kraken_plus_confidence_reports.R "${workdir_results}/taxonomy_classification"

echo "\n\nAll samples were processed successfully!"

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
