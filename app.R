# app.R - Archivo principal de la aplicación FAERS
library(shiny)
library(shinydashboard)
library(DT)
library(dplyr)
library(plotly)
library(arrow)
library(tidyr)
library(shinyWidgets)
library(bs4Dash)

# Cargar los módulos
source("modules/data_functions.R")
source("modules/ui_elements.R")
source("modules/server_functions.R")
source("modules/config.R")

# UI principal completa
library(bs4Dash)

ui <- bs4Dash::dashboardPage(
  title = "FAERS App",
  
  header = bs4Dash::dashboardHeader(
    title = bs4Dash::dashboardBrand(
      title = "FAERS",
      color = "primary"
    )
  ),
  
  sidebar = bs4Dash::dashboardSidebar(disable = TRUE),
  
  body = bs4Dash::dashboardBody(
    # Estilos personalizados
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
      tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css")
    ),
    
    # Componentes principales (los tuyos)
    headerUI(),
    summaryStatsUI(inicializar_datos_resumen()),
    yearButtonsUI(),
    mainContentUI()
  )
)


# Servidor completo
server <- function(input, output, session) {
  # Valor reactivo para el período de tiempo
  periodo <- reactiveVal("all")
  
  # Observadores para los botones de período
  observeEvent(input$allYears, {
    periodo("all")
    updateTabsetPanel(session, "periodoPanel", selected = "allYearsTab")
  })
  
  observeEvent(input$last10Years, {
    periodo("last10")
    updateTabsetPanel(session, "periodoPanel", selected = "last10YearsTab")
  })
  
  # Datos de resumen para los paneles informativos
  datos_resumen <- reactive({
    inicializar_datos_resumen()
  })
  
  # Renderizar paneles de información
  output$totalReportsValue <- renderUI({
    paneles <- crear_panel_informacion(datos_resumen())
    paneles$total
  })
  
  output$seriousReportsValue <- renderUI({
    paneles <- crear_panel_informacion(datos_resumen())
    paneles$serious
  })
  
  output$deathReportsValue <- renderUI({
    paneles <- crear_panel_informacion(datos_resumen())
    paneles$death
  })
  
  # Obtener datos según filtros
  datos_filtrados <- reactive({
    obtener_datos_filtrados(input$reporterType, periodo())
  })
  
  # Renderizar tabla
  output$reportTable <- renderDT({
    crear_tabla_datos(input$reporterType, datos_filtrados())
  })
  
  # Obtener datos para el gráfico
  datos_grafico <- reactive({
    obtener_datos_grafico(input$reporterType, periodo())
  })
  
  # Renderizar gráfico
  output$barChart <- renderPlotly({
    crear_grafico_barras(input$reporterType, datos_grafico())
  })
}

# Ejecutar la aplicación
shinyApp(ui, server)