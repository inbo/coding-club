#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

# CHALLENGE 3

# read dataset - txt file should be placed in the /data folder within the folder
# containing app.R
catch_fl <- read_csv("./data/20231128_geese_counts_cleaned.txt", na = "")
# provinces
provinces <- unique(catch_fl$province)
# species
species <- unique(catch_fl$commonName)


# Define UI for application that draws the plots
ui <- fluidPage(

  # Application title
  titlePanel("catches"),

  # choice of province and species
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        inputId = "prov",
        label = "province",
        choices = provinces,
        selected = "Oost-Vlaanderen"
      ),
      selectInput(
        inputId = "sp",
        label = "species",
        choices = species,
        selected = "Canadese gans"
      )
    ),

    # Show a table with the selected data
    mainPanel(
      plotOutput("plot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$plot <- renderPlot({
    catch_fl %>%
      filter(commonName == input$sp,
             province == input$prov) %>%
      group_by(year) %>%
      summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
      ungroup() %>%
      ggplot(aes(x = year, y = catched_total)) +
      geom_bar(stat = 'identity') +
      scale_x_continuous(breaks = 2012:2018) +
      labs(title = paste("Catches of", input$sp, "in", input$prov))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
