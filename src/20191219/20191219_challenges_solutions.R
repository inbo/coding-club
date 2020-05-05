library(tidyverse)
library(INBOtheme)

# read data
survey <- read_csv("./data/20191219/20191219_survey_cleaned.csv")

## RECAP

# ggplot recipe
ggplot(data = survey,
       mapping = aes(x = weight,
                     y = hindfoot_length,
                     color = sex)) +
  geom_point()

# mapping (aesthetics) can be defined in geometry (and often that's the case)
ggplot(data = survey) +
  geom_point(mapping = aes(x = weight,
                           y = hindfoot_length,
                           color = sex))

# arguments which need columns as values MUST go in aes(), the other ones MUST
# be put out of aes()
# example: no error returned but points transparency is wrong
ggplot(data = survey) +
  geom_point(mapping = aes(x = weight,
                           y = hindfoot_length,
                           color = sex,
                           # this below is not a column! Just a value
                           alpha = 0.01))
# example: this is good
ggplot(data = survey) +
  geom_point(mapping = aes(x = weight,
                           y = hindfoot_length,
                           color = sex),
             alpha = 0.01)


## CHALLENGE 1

fit_results <- read_csv("./data/20191219/20191219_gam_fit_results.csv",
                           na = "")

ggplot(data = fit_results) +
  geom_point(aes(x = year,
                 y = obs)) +
  geom_ribbon(aes(x = year,
                  ymin = lcl,
                  ymax = ucl),
              alpha = 0.3,
              fill = "purple") +
  geom_point(aes(x = year,
                 y = fit),
             color = "red",
             shape = "square") +
  geom_line(aes(x = year,
                y = fit),
            color = "red",
            linetype = "dotted") +
  xlim(c(min(fit_results$year), max(fit_results$year))) +
  ggtitle(label = "Number of observations in Belgian Natura2000 areas",
          subtitle = "Source: GBIF") +
  theme(plot.title = element_text(hjust = 0),
        plot.subtitle = element_text(hjust = 0)) +
  facet_wrap(~scientificName, scales = "free")

## CHALLENGE 2

fit_results_sum <-
  fit_results %>%
  group_by(year) %>%
  summarize(obs = sum(obs, na.rm = TRUE))

main_plot <-
  ggplot(data = fit_results_sum) +
  geom_area(aes(x = year, y = obs)) +
  ggtitle(label = "Number of observations in Belgian Natura2000 areas",
          subtitle = "Source: GBIF") +
  theme(plot.title = element_text(hjust = 0),
        plot.subtitle = element_text(hjust = 0))
main_plot

sub_plots <-
  ggplot(data = fit_results) +
  geom_point(aes(x = year,
                 y = obs)) +
  geom_ribbon(aes(x = year,
                  ymin = lcl,
                  ymax = ucl),
              alpha = 0.3,
              fill = "purple") +
  geom_line(aes(x = year,
                y = fit),
            color = "red",
            linetype = "dotted") +
  facet_wrap(~scientificName, scales = "free")

# egg alternative
egg::ggarrange(main_plot,sub_plots)
# cowplot alternative
cowplot::plot_grid(main_plot, sub_plots, nrow = 2)


## INTERMEZZO
# Play a little with dark themes
install.packages("ggdark")
library(ggdark)

ggplot(data = fit_results %>% filter(scientificName == "Felis catus")) +
  geom_point(aes(x = year,
                 y = obs),
             color = "white") +
  dark_theme_gray() +
  ggtitle("Felis catus: observations in Belgian Natura2000 areas")


## CHALLENGE 3

# Option 1
install.packages("magick")
library(magick)

# Remove subtitle from main plot
main_plot <-
  main_plot +
  ggtitle(label = "Number of observations in Belgian Natura2000 areas",
          subtitle = NULL)

# Use example in https://ropensci.org/blog/2017/08/15/magick-10/ in section
# Native Magick Graphics
complete_plot <- image_graph(res = 96)
cowplot::plot_grid(main_plot, sub_plots, nrow = 2)
dev.off()
link <- "https://github.com/inbo/coding-club/raw/master/docs/assets/images/20191219/20191219_logo_gbif.png"
gbif_logo <- image_read(link)
out <- image_composite(complete_plot,
                       image_scale(gbif_logo, geometry = "x50"))
image_browse(out)

# Option 2

# Basic version to improve
ggplot(survey) +
  geom_point(aes(weight, hindfoot_length, color = sex),
             alpha = 0.3) +
  facet_wrap(~year)

# solution via gganimate
library(lubridate)
library(gganimate)

survey_timestamp <-
  survey %>%
  mutate(timestamp = ymd(paste(year, month, day, sep = "-")))

static_plot <-
  ggplot(survey_timestamp) +
  geom_point(aes(weight, hindfoot_length, color = sex),
             alpha = 0.3)

animation_plot <-
  static_plot +
  labs(title = "hindfoot length vs weight",
       subtitle = 'Time: {frame_time}') +
  transition_time(timestamp) +
  shadow_mark()
animate(animation_plot, fps = 100)
anim_save(animation_plot,
          filename = "animation.gif")


# solution via magick
img_list_plots <- image_graph(res = 96)
map(
  unique(survey$year), function(x) {
    survey_per_year <- survey %>% filter(year <= x)
    xmin <- min(survey$weight, na.rm = TRUE)
    xmax <- max(survey$weight, na.rm = TRUE)
    ymin <- min(survey$hindfoot_length, na.rm = TRUE)
    ymax <- max(survey$hindfoot_length, na.rm = TRUE)
    ggplot(survey_per_year) +
      geom_point(aes(weight, hindfoot_length, color = sex),
                 alpha = 0.3) +
      xlim(c(xmin, xmax)) +
      ylim(c(ymin, ymax)) +
      ggtitle(label = "hindfoot length vs weight",
              subtitle = paste("year:", x))
  }
)

animation <- image_animate(img_list_plots, fps = 5)
image_write(animation, "animation.gif")

