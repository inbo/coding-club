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

# BONUS CHALLENGE 1 - 2

# read dataset - txt file should be placed in the /data folder within the folder
# containing app.R
butterfly_data <- read_csv("./data/20221006_butterflies_data.txt", na = "")
# biotopes
biotopes <- unique(butterfly_data$biotope)
# species
sp <- unique(butterfly_data$species)


# Define UI for application
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

    mainPanel(

      # bonus challenge 1 - uncomment this and comment the next before launching
      # plotOutput("plot"),
      # dataTableOutput("df")

      # bonus challenge 2 - plot and data table in two different tabs
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", plotOutput("plot")),
                  tabPanel("Table", dataTableOutput("df"))
      )

    )
  )
)

# Define server logic required to create plot and data table
server <- function(input, output) {
  # filter data reactively
  dataInput <- reactive(
    butterfly_data %>% dplyr::filter(species == input$s, biotope == input$b)
  )

  output$plot <- renderPlot({
    ggplot(dataInput(), aes(x = year, y = meanArea)) +
      geom_point() +
      geom_smooth() +
      labs(title = paste("Distribution of ", input$s, "- biotope: ", input$b),
           y = "Area (%)") +
      facet_wrap(~ region)
  })

  output$df <- renderDataTable(dataInput())
}

# Run the application
shinyApp(ui = ui, server = server)
