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

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Butterflies - biotopes"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            radioButtons("biotope", "biotope", choices = ""),
            selectInput("species", "species", choices = "")
        ),

        # Show a plot of the generated distribution
        mainPanel(
          tabsetPanel(
            type = "tabs",
            tabPanel("Plot", plotOutput("trend")),
            tabPanel("Tabel", dataTableOutput("tbl"))
          )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  data <- reactiveValues(
    butterfly = read.csv("./data/20221006_butterflies_data.txt", na = ""),
    selected = NULL
  )

  observeEvent(data$butterfly, {
    updateRadioButtons(
      inputId = "biotope", choices = sort(unique(data$butterfly$biotope))
    )
    updateSelectInput(
      inputId = "species", choices = sort(unique(data$butterfly$species))
    )
  })


  observeEvent(input$biotope, {
    if (input$biotope == "") {
      return(NULL)
    }
    data$selected <- data$butterfly %>%
      filter(.data$species == input$species, .data$biotope == input$biotope)
  })

  observeEvent(input$species, {
    if (input$species == "") {
      return(NULL)
    }
    data$selected <- data$butterfly %>%
      filter(.data$species == input$species, .data$biotope == input$biotope)
  })

  output$trend <- renderPlot({
    if (is.null(data$selected)) {
      return(NULL)
    }
    ggplot(data$selected, aes(x = year, y = meanArea)) +
      geom_smooth() +
      geom_point() +
      facet_wrap(~region) +
      ggtitle(paste("Distribotion of", input$species)) +
      ylab("Area (%)")
  })
  output$tbl <- renderDataTable(data$selected)
}

# Run the application
shinyApp(ui = ui, server = server)
