# Packt: Big Data Analytics
# Chapter 8 Tutorial

library(shiny)
library(shinydashboard)
library(data.table)
library(DT)
library(shinyjs)


cms_factor_dt <- readRDS("~/r/rulespackt/cms_factor_dt.rds")
cms_rules_dt <- readRDS("~/r/rulespackt/cms_rules_dt.rds")

# Define UI for application that draws a histogram
ui <- dashboardPage (skin="green",   
       dashboardHeader(title = "Apriori Algorithm"),
       dashboardSidebar(
         useShinyjs(),
         sidebarMenu(
           uiOutput("company"),
           uiOutput("searchlhs"),
           uiOutput("searchrhs"),
           uiOutput("support2"),
           uiOutput("confidence"),
           uiOutput("lift"),
           downloadButton('downloadMatchingRules', "Download Rules")
           
         )
       ),dashboardBody(
         tags$head(
           tags$link(rel = "stylesheet", type = "text/css", href = "packt2.css"),
           tags$link(rel = "stylesheet", type = "text/css", href = "//fonts.googleapis.com/css?family=Fanwood+Text"),
           tags$link(rel = "stylesheet", type = "text/css", href = "//fonts.googleapis.com/css?family=Varela"),
           tags$link(rel = "stylesheet", type = "text/css", href = "fonts.css"),
           
           tags$style(type="text/css", "select { max-width: 200px; }"),
           tags$style(type="text/css", "textarea { max-width: 185px; }"),
           tags$style(type="text/css", ".jslider { max-width: 200px; }"),
           tags$style(type='text/css', ".well { max-width: 250px; padding: 10px; font-size: 8px}"),
           tags$style(type='text/css', ".span4 { max-width: 250px; }")
           
           
         ),
         
         fluidRow(
           dataTableOutput("result")
           
         )
       ),
       title = "Aprior Algorithm"
)



# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  PLACEHOLDERLIST2 <- list(
    placeholder = 'Select All',
    onInitialize = I('function() { this.setValue(""); }')
  )
  
  output$company <- renderUI({
    datasetList <- c("Select All",as.character(unique(sort(cms_factor_dt$company))))
    selectizeInput("company", "Select Company" , 
                   datasetList, multiple = FALSE,options = PLACEHOLDERLIST2,selected="Select All")
  })
  
  output$searchlhs <- renderUI({
    textInput("searchlhs", "Search LHS", placeholder = "Search")
  })
  
  output$searchrhs <- renderUI({
    textInput("searchrhs", "Search RHS", placeholder = "Search")
  })
  
  output$support2 <- renderUI({
    sliderInput("support2", label = 'Support',min=0,max=0.04,value=0.01,step=0.005)
  })
  
  output$confidence <- renderUI({
    sliderInput("confidence", label = 'Confidence',min=0,max=1,value=0.5)
  })
  
  output$lift <- renderUI({
    sliderInput("lift", label = 'Lift',min=0,max=10,value=0.8)
  })
  
  dataInput <- reactive({
    print(input$support2)
    print(input$company)
    print(identical(input$company,""))

    temp <- cms_rules_dt[support > input$support2 & confidence > input$confidence & lift > input$lift]
    
    if(!identical(input$searchlhs,"")){
      searchTerm <- paste0("*",input$searchlhs,"*")
      temp <- temp[LHS %like% searchTerm]
    }
    
    if(!identical(input$searchrhs,"")){
      searchTerm <- paste0("*",input$searchrhs,"*")
      temp <- temp[RHS %like% searchTerm]
    }
    
    if(!identical(input$company,"Select All")){
      # print("HERE")
      temp <- temp[grepl(input$company,rules)]
    }
    temp[,.(LHS,RHS,support,confidence,lift)]
  })
  
  output$downloadMatchingRules <- downloadHandler(
    filename = "Rules.csv",
    content = function(file) {
      write.csv(dataInput(), file, row.names=FALSE)
    }
  )
  
  output$result <- renderDataTable({
    z = dataInput()
    if (nrow(z) == 0) {
      z <- data.table("LHS" = '', "RHS"='', "Support"='', "Confidence"='', "Lift" = '')
    }
    setnames(z, c("LHS", "RHS", "Support", "Confidence", "Lift"))
    datatable(z,options = list(scrollX = TRUE))
  })
  
} 

shinyApp(ui = ui, server = server)
