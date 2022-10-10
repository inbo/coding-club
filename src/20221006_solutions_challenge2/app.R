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
    titlePanel("butterflies - biotopes"),

    # choice of biotope and species
    sidebarLayout(
        sidebarPanel(
          radioButtons(
            inputId = "b",
            label = "biotope",
            choices = c("Agriculture", "Forest", "Open", "Urban")
            ),
          selectInput(
            inputId = "s",
            label = "species",
            choices = c("Limenitis camilla", "Pararge aegeria")
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
    paste("You have selected the biotope", input$b, "and the species", input$s)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
