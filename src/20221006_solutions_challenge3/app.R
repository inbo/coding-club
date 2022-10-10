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
butterfly_data <- read_csv("./data/20221006_butterflies_data.txt", na = "")
# biotopes
biotopes <- unique(butterfly_data$biotope)
# species
sp <- unique(butterfly_data$species)


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("butterflies - biotopes"),

    # choice of biotope and species
    sidebarLayout(
        sidebarPanel(
          radioButtons(
            inputId = "b",
            label = "biotope",
            choices = biotopes
            ),
          selectInput(
            inputId = "s",
            label = "species",
            choices = sp
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
    ggplot(butterfly_data %>%
             filter(species == input$s,
                    biotope == input$b),
           aes(x = year,
               y = meanArea)) +
      geom_point() +
      geom_smooth() +
      labs(title = paste("Distribution of ", input$s, "- biotope:", input$b),
           y = "Area (%)") +
      facet_wrap(~ region)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
