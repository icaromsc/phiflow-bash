library(ggplot2)
library(plotly)
library(viridis)
library(ggpubr)

df <- read.table("kraken2_plus_conifer_joined_ouputs.tsv", sep = "\t", header = T,fill = TRUE)

########## PLOT RESULTS #############


#Set theme for plots
theme_set(theme_pubr(legend = "left"))

#DEFAULT CONFIDENCE SCORE
pp <- df %>%
  filter(rank=="S1" | rank=="S2" | rank=="S") %>%
  filter(taxon_name!="Homo sapiens") %>%
  ggplot(aes(x = log2(fragments_root), y = log2(distinct_minimizers))) +
  geom_point(aes(color=P50_conf, name=taxon_name)) +
  ggtitle("Before filtering") +
  scale_colour_viridis(option = "C",alpha = 0.9) + scale_shape_manual(values=c(16,4))
pp
ggplotly()

#APLYING FILTERING
p <- df %>%
  filter(rank=="S1" | rank=="S2" | rank=="S") %>%
  filter(taxon_name!="Homo sapiens" & distinct_minimizers>=10 & fragments_root>=10 & P50_conf >= 0.4) %>%
  ggplot(aes(x = log2(fragments_root), y = log2(distinct_minimizers))) +
  geom_point(aes(color=P50_conf, name=taxon_name)) +
  ggtitle("After filtering") +
  scale_colour_viridis(option = "C",alpha = 0.9, begin = 0.4)

p
# Plot the scatter plot with marginal histograms
library(ggExtra)


plot1 <- ggMarginal(pp, fill=4,alpha=0.3,type = "densigram")
plot1
#ggMarginal(pp, fill=4,alpha=0.3)
plot2 <- ggMarginal(p, fill=4,alpha=0.3,type = "densigram")
plot2
#ggMarginal(p, fill=4,alpha=0.3)

pdf("kraken2_confidence_scores_filtering.pdf",width = 10,height = 5)

pp_marg <- ggMarginal(pp + theme(legend.position = "none") + ggtitle(""), fill=4,alpha=0.3, type = "densigram")
p_marg <- ggMarginal(p + theme(legend.position = "none") +ggtitle(""), fill=4,alpha=0.3, type = "densigram")

ggpubr::ggarrange(pp_marg,
                  p_marg,align = "h",labels = c("After filtering","Before filtering"))

#Without legends
theme_set(theme_pubclean())
pp_marg <- ggMarginal(pp + theme(legend.position = "left") + ggtitle(""), fill=4,alpha=0.3, type = "densigram")
p_marg <- ggMarginal(p + theme(legend.position = "left") +ggtitle(""), fill=4,alpha=0.3, type = "densigram")

ggpubr::ggarrange(pp_marg,
                  p_marg,align = "h",labels = c("After filtering","Before filtering"))
dev.off()