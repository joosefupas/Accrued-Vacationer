library(shiny)

ui <- fluidPage(
  titlePanel("Holiday Calculator"),
  tabsetPanel(
    tabPanel("Calculator",
             sidebarLayout(
               sidebarPanel(
                 numericInput("initial_hours", "Initial Holiday Hours", value = 14.66),
                 numericInput("monthly_accrual", "Monthly Accrual Hours", value = 13.86),
                 dateInput("start_date", "Start Date", value = as.Date("2023-10-16")),
                 dateInput("end_date", "End Date", value = as.Date("2024-05-16")),
                 numericInput("working_day_hours", "Working Day Hours", value = 8),
                 actionButton("calculate", "Calculate")
               ),
               mainPanel(
                 verbatimTextOutput("results_text"),
                 actionButton("show_table", "Show Results Table")
               )
             )
    ),
    tabPanel("About",
             HTML("<h2>About the Author</h2>
           <p>Author: <b>Giuseppe Pasculli</b></p>
           <p>GitHub: <a href='https://github.com/joosefupas' target='_blank'>@joosefupas</a></p>
           <h2>Parameter Information</h2>
           <p><b>Initial Holiday Hours:</b> The number of holiday hours you currently have.</p>
           <p><b>Monthly Accrual Hours:</b> The number of holiday hours you accrue each month.</p>
           <p><b>Start Date:</b> The start date of the calculation period.</p>
           <p><b>End Date:</b> The end date of the calculation period.</p>
           <p><b>Working Day Hours:</b> The number of hours you work per day (default is 8).</p>")
    )
  )
)

server <- function(input, output, session) {
  calculate_holiday_data <- eventReactive(input$calculate, {
    dates <- seq(input$start_date, input$end_date, by = "1 month")
    total_hours <- input$initial_hours + (seq_along(dates) - 1) * input$monthly_accrual
    total_working_days <- round(total_hours / input$working_day_hours, 2)
    data.frame(
      Date = format(dates, format = "%d-%b-%Y"),
      "Total Hours Earned/Collected" = total_hours,
      "Total Working Days" = total_working_days
    )
  })
  
  observeEvent(input$calculate, {
    showModal(modalDialog(
      title = "Results",
      tableOutput("holiday_table"),
      footer = actionButton("close_modal", "Close")
    ))
  })
  
  output$holiday_table <- renderTable({
    calculate_holiday_data()
  })
  
  observeEvent(input$show_table, {
    showModal(modalDialog(
      title = "Results",
      tableOutput("holiday_table"),
      footer = actionButton("close_modal", "Close")
    ))
  })
  
  observeEvent(input$close_modal, {
    removeModal()
  })
  
  output$results_text <- renderText({
    if (input$calculate > 0) {
      "Results are ready. Click 'Show Results Table' to view."
    } else {
      ""
    }
  })
}

shinyApp(ui, server)
