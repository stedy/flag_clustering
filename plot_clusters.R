library(dplyr)
library(factoextra)
library(reshape)

options(ggrepel.max.overlaps = 40)
`%notin%` <- function(x,y) !(x %in% y)

raw_data <- read.csv("colorgram_cols.csv")
color_palette <- unique(raw_data$colors)
countries <- unique(raw_data$country)

summary_df <-
  raw_data %>%
  group_by(country, colors) %>%
  mutate(color_proportion = sum(proportion)) %>%
  select(country, colors, color_proportion) %>%
  distinct()

summary_df_zeros <- c()
for(x in countries){
  temp <- subset(summary_df, summary_df$country == x)
  temp_not_col <- setdiff(color_palette, temp$colors)
  temp_zero_df <- data.frame(country = x, colors = temp_not_col, color_proportion = 0)
  temp_combined_zeros <- rbind(temp, temp_zero_df)
  summary_df_zeros <- rbind(summary_df_zeros, temp_combined_zeros)
}

summary_wide <- cast(summary_df_zeros, country ~ colors)
scaled_df <- scale(summary_wide)
k2 <- kmeans(scaled_df, centers=3, nstart=100)

#small example with just South American countries

sa <- c("brazil", "argentina", "colombia", "venezuela", "peru",
        "paraguay", "uruguay", "bolivia", "ecuador", "suriname",
        "guyana")
sa_temp <- subset(scaled_df, rownames(scaled_df) %in% sa)
sa_temp <- sa_temp[,colnames(sa_temp) != "orange"]
k2_sa <- kmeans(sa_temp, centers=3, nstart=10)

png("sa_cluster.png")
fviz_cluster(k2_sa, data = sa_temp, ellipsis=F, geom="text", repel=T,
             labelsize = 16,
             ggtheme = theme_light(),
             main = "Cluster plot of country flags of South America")
dev.off()

#then create with all flags

png("all_flags_cluster.png", width=1000, height=800, units="px")
fviz_cluster(k2, data = scaled_df, repel=T, ellipse.type = "norm", geom="text",
             ellipsis=F,
             ggtheme = theme_light(),
             labelsize = 16,
             main = "Cluster plot of all world flags")
dev.off()
