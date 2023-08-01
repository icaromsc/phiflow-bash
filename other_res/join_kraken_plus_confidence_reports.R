library(stringr)

#default filtering parameters
min_distinct_kmers_threshold <- 10
min_assigned_reads <- 10
min_confidence_score <- 0.4

# Set the working directory to the directory containing the TSV files
setwd("~/Documentos/metatranscriptomics_benchmarking/")

# Get a list of all the TSV files in the directory
file_list <- list.files(pattern = "\\.k2.report$")

#Create column names to add to data frames 
c_names <- c("percentage","fragments_root","fragments_taxon",
             "minimizers","distinct_minimizers","rank","taxon_id","name")


# Create an empty list to hold the dataframes
df_list <- list()


# Loop through the file list and read each file into a dataframe
for (i in 1:length(file_list)) {
  sample <- str_split(file_list[i], ".k2.report")[[1]][1]
  #str_split(file_list[i], ".k2.report")
  print(sample)
  #Open kraken2 output report
  temp_kraken2_table <- read.table(paste0("K2_reports/",file_list[i]), sep = "\t", header = F,fill = TRUE)
  
  #add column names
  colnames(temp_kraken2_table) <- c_names
  
  #Open Conifer Confidence scores output
  temp_kraken2_scores <- read.table(paste0("K2_scores/",sample,".k2.score"),sep = "\t", header = T, fill=TRUE)
  #Change taxid column 
  temp_kraken2_scores$taxon_id <- temp_kraken2_scores$taxid
  temp_kraken2_scores$taxid <- NULL
  
  #Join kraken2 and confidence score tables by taxon id
  joined_kraken2_scores <- left_join(temp_kraken2_table,temp_kraken2_scores)
  #add SRA id
  joined_kraken2_scores$SRA_ID <- sample 
  
  
  #df_list[[i]] <- temp_kraken2_table
  df_list[[i]] <- joined_kraken2_scores
}

#str_split(file_list[2], ".k2.report")[1]

# # Loop through the file list and read each file into a dataframe
# for (i in 1:length(file_list)) {
#   sample <- str_split(file_list[i], ".k2.report")[[1]][1]
#   #str_split(file_list[i], ".k2.report")
#   print(sample)
#   #Open kraken2 output report
#   temp_kraken2_table <- read.table(paste0("K2_reports/",file_list[i]), sep = "\t", header = F,fill = TRUE)
#   
#   #add column names
#   colnames(temp_kraken2_table) <- c_names
#   #add SRA id
#   temp_kraken2_table$SRA_ID <- sample 
#   #print(head(temp_kraken2_table))
#   
#   
#   df_list[[i]] <- temp_kraken2_table
#   
# }



# Merge all dataframes into a single dataframe in long format
library(dplyr)
library(tidyr)

df <- df_list %>%
  bind_rows()

#Save results
write.table(df,"kraken2_plus_conifer_joined_ouputs.tsv",
            quote = F,
            sep = "\t", row.names = F)


#Function to generate taxonomic composition matrix in different taxon ranks
#also returns already filtered or raw composition matrix
generate_composition_matrix <- function(df,taxonomic_level="Species",filtered=T){
  
  result_df=data.frame()
  
  if (filtered) {
    # Filter dataframe using specified thresholds 
    # to remove false positive at species level
    # exclude human host assigned reads
    result_df <- df %>%
      filter(taxon_name!="Homo sapiens") %>%
      filter(distinct_minimizers >= min_distinct_kmers_threshold) %>%
      filter(fragments_root >= min_assigned_reads) %>% 
      filter(P50_conf >= min_confidence_score)
  }else{
    # exclude human host assigned reads
    result_df <- df %>%
      filter(taxon_name!="Homo sapiens")
  }
  
  processed_df <- result_df
  
  if(taxonomic_level=="Genus"){
    processed_df <- processed_df %>%
      filter(rank=="G")
  }else{
    processed_df <- processed_df %>%
      filter(rank=="S1" | rank=="S2" | rank=="S")
  }
  
  #Subset data
  subset_df <- processed_df %>% 
    select(taxon_id,taxon_name,fragments_root,SRA_ID)
  
  ######################################################
  ## CONVERT TAXON TABLE IN LONG TO WIDE FORMAT ########
  ######################################################
  taxon_composition_matrix <- subset_df %>% 
    pivot_wider(id_cols = c("taxon_id","taxon_name"),
                names_from = "SRA_ID",
                values_from = "fragments_root",
                values_fill = 0)
  
  return(taxon_composition_matrix)
}

#Obtain composition matrices

species_composition_matrix_filtered <- generate_composition_matrix(df = df,
                                                                   taxonomic_level = "Species",
                                                                   filtered = T)

species_composition_matrix_raw <- generate_composition_matrix(df=df,
                                                              taxonomic_level = "Species",
                                                              filtered = F)

genus_composition_matrix_filtered <- generate_composition_matrix(df = df,
                                                                 taxonomic_level = "Genus",
                                                                 filtered = T)

genus_composition_matrix_raw <- generate_composition_matrix(df = df,
                                                            taxonomic_level = "Genus",
                                                            filtered = F)

### Save results
write.table(species_composition_matrix_filtered,
            "species_composition_matrix_filtered.tsv",
            sep = "\t",
            quote = F,
            row.names = F)

write.table(genus_composition_matrix_filtered,
            "genus_composition_matrix_filtered.tsv",
            sep = "\t",
            quote = F,
            row.names = F)

### Save results
write.table(species_composition_matrix_raw,
            "species_composition_matrix_raw.tsv",
            sep = "\t",
            quote = F,
            row.names = F)

write.table(genus_composition_matrix_raw,
            "genus_composition_matrix_raw.tsv",
            sep = "\t",
            quote = F,
            row.names = F)

















#Exclude human host assigned reads
no_filtered_df <- df %>%
  filter(name!="Homo sapiens")

no_filtered_df_species <- no_filtered_df %>%
  filter(rank=="S1" | rank=="S2" | rank=="S")

no_filtered_df_genus <- no_filtered_df %>%
  filter(rank=="G")


# Filter dataframe using specified thresholds 
# to remove false positive at species level
# exlude homo sapiens assigned reads

#filtered_df <- df %>%
#  filter(taxon_name!="Homo sapiens" & distinct_minimizers >= min_distinct_kmers_threshold & fragments_root >= min_assigned_reads & P50_conf >= min_confidence_score)

filtered_df <- df %>%
  filter(taxon_name!="Homo sapiens") %>%
  filter(distinct_minimizers >= min_distinct_kmers_threshold) %>%
  filter(fragments_root >= min_assigned_reads) %>% 
  filter(P50_conf >= min_confidence_score)

filtered_df_species <- filtered_df %>%
  filter(rank=="S1" | rank=="S2" | rank=="S")

filtered_df_genus <- filtered_df %>%
  filter(rank=="G")

#Subset dataframe to extract only important variables
subset_df_species <- filtered_df_species %>% 
  select(taxon_id,taxon_name,fragments_root,SRA_ID)

subset_df_genus <- filtered_df_genus %>% 
  select(taxon_id,taxon_name,fragments_root,SRA_ID)

#Subset dataframe to extract only important variables
subset_df_species <- filtered_df_species %>% 
  select(taxon_id,taxon_name,fragments_root,SRA_ID)

subset_df_genus <- filtered_df_genus %>% 
  select(taxon_id,taxon_name,fragments_root,SRA_ID)
library(tidyr)

######################################################
## CONVERT TAXON TABLE IN LONG TO WIDE FORMAT ########
######################################################

species_composition_matrix <- subset_df_species %>% 
   pivot_wider(id_cols = c("taxon_id","taxon_name"),
                          names_from = "SRA_ID",
               values_from = "fragments_root",
               values_fill = 0)

genus_composition_matrix <- subset_df_genus %>% 
  pivot_wider(id_cols = c("taxon_id","taxon_name"),
              names_from = "SRA_ID",
              values_from = "fragments_root",
              values_fill = 0)



