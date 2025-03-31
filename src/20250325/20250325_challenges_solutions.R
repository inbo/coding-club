library(tidyverse)
library(colorblindr)
library(paletteer)

occs_benelux <- readr::read_tsv("data/20250325/20250325_occs_benelux.tsv")
species_be <- readr::read_tsv("data/20250325/20250325_species_in_BE.tsv")

occs_benelux_animals <- occs_benelux %>%
  dplyr::filter(kingdom == "Animalia")

# Challenge 1 ####

## 1.1, 1.2, 1.3, 1.4 ####
p <- ggplot(occs_benelux_animals) +
  geom_point(aes(x = year, y = count, color= country)) +
  labs(title = "GBIF occurrence records in the Benelux",
       x = "year",
       y = "number of occurrences"
  ) +
  # Use log10 scale
  scale_y_log10() +
  # Add smoother lines
  geom_smooth(aes(x = year, y = count, color = country),
              method = "loess",
              # se is by default TRUE, but we can be explicit
              se = TRUE)

## 1.5 ####
# Convert to bar plot (without smoother) -> too many years means too many lines,
# especially because we have 3 different countries! So, if in theory a bar plot
# is a good idea, in practice it might not be the best choice.
ggplot(occs_benelux_animals) +
  geom_col(aes(x = year, y = count, fill = country), position = "dodge") +
  labs(title = "GBIF occurrence records in the Benelux",
       x = "year",
       y = "number of occurrences"
  ) +
  # Use log10 scale
  scale_y_log10() +
  # Adjust y-range to better show the data
  coord_cartesian(ylim = c(1, 10000000))


# Challenge 2 ####

## 2.1 ####

# Use `"black"` for Belgium, `"skyblue"` for The Netherlands and `"tomato"` for Luxembourg.
p_manual_colors <- p +
  # Use named vector to be sure the colors are assigned correctly (no order issues)
  scale_color_manual(values = c("LU" = "tomato", "NL" = "skyblue", "BE" = "black"))
p_manual_colors


## 2.2 ####

# Use their correspondent hexcodes
p_hex_colors <- p +
  scale_color_manual(values = c("LU" = "#FF6347", "NL" = "#87CEEB", "BE" = "#000000"))
p_hex_colors


## 2.3 ####

# Use the viridis palette. Not the `_d` suffix indicating we are using the discrete version
p_viridis <- p +
  scale_colour_viridis_d()
p_viridis


## 2.4 #### Don't forget to add
p_acanthurus_leucosternon <- p +
  scale_colour_paletteer_d("fishualize::Acanthurus_leucosternon") #Don't forget to add the package where the color comes from like "fishualize::"
p_acanthurus_leucosternon


## 2.5 ####
cvd_grid(p_hex_colors)
cvd_grid(p_acanthurus_leucosternon)


# CHALLENGE 3A ####

## 3A.1 ####
occs_benelux %>%
  ggplot() +
  geom_point(aes(x = year, y = count, color = country)) +
  labs(title = "GBIF occurrence records in the Benelux",
       x = "year",
       y = "number of occurrences"
  ) +
  scale_y_log10() +
  geom_smooth(aes(x = year, y = count, color = country),
              method = "loess",
              se = TRUE) +
  facet_grid(~kingdom)

## 3A.2 ####
occs_benelux %>%
  ggplot() +
  geom_point(aes(x = year, y = count, color = country)) +
  labs(title = "GBIF occurrence records in the Benelux",
       x = "year",
       y = "number of occurrences"
  ) +
  scale_y_log10() +
  geom_smooth(aes(x = year, y = count, color = country),
              method = "loess",
              se = TRUE) +
  facet_wrap(~kingdom)


# Challenge 3B ####

# Code for plot with faceting in screenshot
n_species_per_order_iucn <- species_be %>%
  group_by(phylum, order, iucnRedListCategory) %>%
  summarise(n_species = n_distinct(species)) %>%
  arrange(desc(n_species))
n_species_per_order_iucn

n_species_per_order_iucn %>%
  ggplot() +
  geom_col(aes(x = order, y = n_species, fill = iucnRedListCategory), position = "dodge") +
  labs(title = "Number of species per order and IUCN red list category",
       x = "order",
       y = "number of species"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_grid(phylum ~ iucnRedListCategory, scales = "free")

## Something better? ####
## OPTION 1
#check how many observations there are in each cell:

n_species_per_order_iucn %>%
  group_by(phylum, iucnRedListCategory) %>%
  summarize(n = n())
#there are only onbservations in each cell for phylum == "Tracheophyta" and for iucnRedListCategory == "NE"
#We can split up the graph:
n_species_per_order_iucn %>%
  dplyr::filter(iucnRedListCategory == "NE") %>%
  ggplot() +
  geom_col(aes(x = order, y = n_species), position = "dodge") +
  labs(title = "Number of species per order for the IUCN red list category `NE`",
       x = "order",
       y = "number of species"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(vars(phylum), scales = "free")

n_species_per_order_iucn %>%
  dplyr::filter(phylum == "Tracheophyta") %>%
  ggplot() +
  geom_col(aes(x = order, y = n_species), position = "dodge") +
  labs(title = "Number of species for Tracheophyta in each IUCN red list category",
       x = "order",
       y = "number of species"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_grid(vars(iucnRedListCategory), scales = "free")

## OPTION 2
## use drop = TRUE in the facet_wrap:
n_species_per_order_iucn <- species_be %>%
  group_by(phylum, order, iucnRedListCategory) %>%
  summarise(n_species = n_distinct(species)) %>%
  arrange(desc(n_species))
n_species_per_order_iucn

n_species_per_order_iucn %>%
  ggplot(mapping = aes(x = order,
                       y = n_species,
                       fill = iucnRedListCategory)) +
  facet_wrap(phylum ~ iucnRedListCategory,
             scales = "free",
             drop = TRUE) +
  scale_x_discrete(guide = guide_axis(n.dodge=2)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# BONUS CHALLENGE ####

n_species_region <- species_be %>%
  group_by(inFlanders, inWallonia, inBrussels) %>%
  summarise(n_species = n_distinct(species)) %>%
  arrange(desc(n_species))
n_species_region

## Option with VennDiagram ####
library(VennDiagram)
venn.diagram(
  x = list(
    Flanders = species_be %>%
      dplyr::filter(inFlanders & !is.na(species)) %>%
      dplyr::pull(species) %>%
      unique(),
    Wallonia = species_be %>%
      dplyr::filter(inWallonia & !is.na(species)) %>%
      dplyr::pull(species) %>%
      unique(),
  Brussels = species_be %>%
    dplyr::filter(inBrussels & !is.na(species)) %>%
    dplyr::pull(species) %>%
    unique()),
  filename = 'src/20250325/venn.png',
  output = TRUE ,
  imagetype = "png" ,
  height = 480 ,
  width = 480 ,
  resolution = 300,
  compression = "lzw",
  lwd = 1,
  col = c("#440154ff", '#21908dff', '#fde725ff'),
  fill = c(alpha("#440154ff", 0.3), alpha('#21908dff', 0.3),
           alpha('#fde725ff', 0.3)),
  cex = 0.5,
  fontfamily = "sans",
  cat.cex = 0.3,
  cat.default.pos = "outer",
  cat.pos = c(-27, 27, 135),
  cat.dist = c(0.055, 0.055, 0.085),
  cat.fontfamily = "sans",
  cat.col = c("#440154ff", '#21908dff', '#fde725ff'),
  rotation = 1)
