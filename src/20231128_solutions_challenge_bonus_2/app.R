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

# Define UI for application
ui <- fluidPage(

  # Application title
  titlePanel("catches"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      radioButtons(inputId = "prov",
                   label = "province",
                   choices = ""),
      selectInput(inputId = "sp",
                  label = "species",
                  choices = "")
    ),

    # Show a table with the selected data
    mainPanel(
      plotOutput("plot"),
      dataTableOutput("df")
    )
  )
)

# Define server logic required to create plot and data table in a tabset
# reactively
server <- function(input, output) {
  data <- reactiveValues(
    catches = read_csv("./data/20231128_geese_counts_cleaned.txt", na = ""),
    selected = NULL
  )

  observeEvent(data$catches, {
    updateRadioButtons(
      inputId = "prov", choices = sort(unique(data$catches$province))
    )
    updateSelectInput(
      inputId = "sp", choices = sort(unique(data$catches$commonName))
    )
  })


  observeEvent(input$prov, {
    if (input$prov == "") {
      return(NULL)
    }
    data$selected <- data$catches %>%
      filter(.data$commonName == input$sp,
             .data$province == input$prov) %>%
      group_by(year) %>%
      summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
      ungroup()
  })

  observeEvent(input$sp, {
    if (input$sp == "") {
      return(NULL)
    }
    data$selected <- data$catches %>%
      filter(.data$commonName == input$sp,
             .data$province == input$prov) %>%
      group_by(year) %>%
      summarize(catched_total = sum(catched, na.rm = TRUE)) %>%
      ungroup()
  })

  output$plot <- renderPlot({
    if (is.null(data$selected)) {
      return(NULL)
    }

    ggplot(data$selected,
           aes(x = year, y = catched_total)) +
      geom_bar(stat = 'identity') +
      scale_x_continuous(breaks = 2012:2018) +
      labs(title = paste("Catches of", input$sp, "in", input$prov))
  })
  output$tbl <- renderDataTable(data$selected)
}

# Run the application
shinyApp(ui = ui, server = server)
