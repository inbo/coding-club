#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# CHALLENGE 2

# Define UI for application that prints a text with the choices
ui <- fluidPage(

  # Application title
  titlePanel("catches"),

  # choice of biotope and species
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        inputId = "prov",
        label = "province",
        choices = c("Antwerpen",
                    "Limburg",
                    "Oost-Vlaanderen",
                    "Vlaams-Brabant",
                    "West-Vlaanderen"),
        selected = "Oost-Vlaanderen"
      ),
      selectInput(
        inputId = "sp",
        label = "species",
        choices = c("Nijlgans",
                    "Grauwe gans",
                    "Soepgans",
                    "Canadese gans",
                    "Brandgans"),
        selected = "Canadese gans"
      )
    ),

    # Show a table with the selected data
    mainPanel(
      textOutput("selected_var")
    )
  )
)

# Define server logic required to print the user choices as text
server <- function(input, output) {
  output$selected_var <- renderText({
    paste("You have selected the province",
          input$prov,
          "and the species",
          input$sp
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
