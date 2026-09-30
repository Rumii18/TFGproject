library(shiny)
library(TFGproject) 

# 1. USER INTERFACE (UI)
ui <- fluidPage(
  titlePanel("Marascuilo Procedure - TFGproject"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Upload your dataset (CSV)",
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      
      tags$hr(),
      
      uiOutput("column_selectors"),
      
      actionButton("run_analysis", "Run Analysis", class = "btn-primary", width = "100%")
    ),
    
    mainPanel(
      h4("Numerical Results"),
      verbatimTextOutput("text_output"),
      
      tags$hr(),
      
      h4("Interval Visualization"),
      plotOutput("plot_output")
    )
  )
)

# 2. SERVER LOGIC
server <- function(input, output, session) {
  
  dataset <- reactive({
    req(input$file1)
    read.csv(input$file1$datapath, stringsAsFactors = TRUE)
  })
  
  output$column_selectors <- renderUI({
    req(dataset())
    df <- dataset()
    cols <- names(df)
    
    tagList(
      selectInput("col_group", "Select Group Column:", choices = cols),
      selectInput("col_response", "Select Response Column:", choices = cols),
      textInput("val_success", "Enter Success Value:", placeholder = "e.g., 'Success' (case sensitive)")    )
  })
  
  marascuilo_results <- eventReactive(input$run_analysis, {
    req(dataset(), input$col_group, input$col_response, input$val_success)
    
    marascuilo_test(
      df = dataset(),
      col_grupo = input$col_group,
      col_respuesta = input$col_response,
      valor_exito = input$val_success
    )
  })
  
  output$text_output <- renderPrint({
    req(marascuilo_results())
    print(marascuilo_results())
  })
  
  output$plot_output <- renderPlot({
    req(marascuilo_results())
    plot(marascuilo_results())
  })
}

# 3. RUN APP
shinyApp(ui = ui, server = server)