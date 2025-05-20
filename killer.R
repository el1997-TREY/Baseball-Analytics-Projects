setwd("~/Downloads")
library(shiny)
library(grid)
library(gridExtra)
library(dplyr)
library(tidyr)

killerdata <- read.csv("killer_data.csv")

stat_labels <- c(
  ppa = "Pitches Per PA",
  bb_percent = "Walk Rate",
  xslg = "Expected SLG",
  squared_up_swing = "Squared-Up Rate",
  exit_velocity_avg = "Average Exit Velo",
  oz_swing_percent = "Chase Rate",
  whiff_percent = "Whiff Rate",
  flyballs_percent = "Fly Ball",
  hitcountrate = "Hitter's Count Rate"
)

batter_score_weights <- c(
  xslg = 0.20,
  bb_percent = 0.15,
  whiff_percent = 0.10,
  oz_swing_percent = 0.10,
  ppa = 0.10,
  exit_velocity_avg = 0.15,
  flyballs_percent = 0.05,
  squared_up_swing = 0.05,
  hitcountrate = 0.10
)

ui <- fluidPage(
  titlePanel("Batter Comparison Killer Plot"),
  sidebarLayout(
    sidebarPanel(
      selectInput("batter1", "Select Batter 1:", choices = unique(killerdata$last_first)),
      selectInput("batter2", "Select Batter 2:", choices = unique(killerdata$last_first),
                  selected = unique(killerdata$last_first)[2])
    ),
    mainPanel(
      splitLayout(cellWidths = c("50%", "50%"),
                  plotOutput("plot1", height = "700px"),
                  plotOutput("plot2", height = "700px")),
      br(),
      div(
        style = "text-align: center; margin-top: -10px;",
        span(textOutput("preferredBatter"),
             style = "font-size: 26px; font-weight: bold; color: black;"),
        br(),
        span(textOutput("scoreDifference"),
             style = "font-size: 18px; font-weight: normal; color: gray;")
      )
    )
  )
)

server <- function(input, output) {
  get_player_data <- reactive({
    req(input$batter1, input$batter2)
    killerdata %>%
      filter(last_first %in% c(input$batter1, input$batter2))
  })
  
  normalize_stat <- function(x) {
    ecdf(x)(x) * 100
  }
  
  draw_profile_card <- function(player_row, player_percentiles, opponent_percentiles, score_color) {
    stats <- names(player_percentiles)
    stat_labels_clean <- stat_labels[stats]
    player_score <- sum(player_percentiles[stats] * batter_score_weights[stats], na.rm = TRUE)
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(length(stats) + 3, 3,
                                               widths = unit(c(0.4, 0.4, 0.2), "npc"))))
    grid.text(player_row$last_first,
              vp = viewport(layout.pos.row = 1, layout.pos.col = 1:2),
              gp = gpar(fontsize = 20, fontface = "bold"))
    grid.text("Percentile",
              vp = viewport(layout.pos.row = 1, layout.pos.col = 3),
              gp = gpar(fontsize = 12, fontface = "bold"))
    for (i in seq_along(stats)) {
      stat <- stats[i]
      p_val <- player_percentiles[stat]
      o_val <- opponent_percentiles[stat]
      p_val_clean <- ifelse(is.na(p_val), 0, p_val)
      o_val_clean <- ifelse(is.na(o_val), 0, o_val)
      p_val_clean <- max(min(p_val_clean, 100), 0)
      o_val_clean <- max(min(o_val_clean, 100), 0)
      pct_to_pos <- function(pct) 0.05 + 0.9 * (pct / 100)
      bg_color <- if (p_val_clean > o_val_clean) "palegreen3" else if (p_val_clean < o_val_clean) "indianred2" else "gray80"
      row_index <- i + 1
      for (col in 1:3) {
        grid.rect(gp = gpar(col = NA, fill = bg_color),
                  vp = viewport(layout.pos.row = row_index, layout.pos.col = col))
      }
      grid.text(stat_labels_clean[i],
                just = "left", x = unit(0.01, "npc"),
                gp = gpar(fontsize = 10, fontface = "bold"),
                vp = viewport(layout.pos.row = row_index, layout.pos.col = 1))
      grid.rect(x = unit(0.5, "npc"), width = unit(0.9, "npc"), height = unit(0.6, "lines"),
                gp = gpar(col = NA, fill = "gray90"),
                vp = viewport(layout.pos.row = row_index, layout.pos.col = 2))
      grid.rect(x = unit(pct_to_pos(p_val_clean), "npc"),
                width = unit(0.015, "npc"), height = unit(0.6, "lines"),
                gp = gpar(col = NA, fill = "black"),
                vp = viewport(layout.pos.row = row_index, layout.pos.col = 2))
      grid.text(round(p_val_clean),
                x = unit(0.5, "npc"), y = unit(0.5, "npc"),
                gp = gpar(fontsize = 9, fontface = "bold"),
                vp = viewport(layout.pos.row = row_index, layout.pos.col = 3))
    }
    grid.text(paste("Score:", round(player_score, 1)),
              gp = gpar(fontsize = 14, fontface = "bold", col = score_color),
              vp = viewport(layout.pos.row = length(stats) + 2, layout.pos.col = 1:3))
  }
  
  calculate_scores <- reactive({
    stats <- names(stat_labels)
    percentiles_df <- killerdata
    for (stat in stats) {
      percentiles_df[[paste0(stat, "_pct")]] <- normalize_stat(percentiles_df[[stat]])
    }
    
    p1 <- killerdata %>% filter(last_first == input$batter1)
    p2 <- killerdata %>% filter(last_first == input$batter2)
    
    p1_percentiles <- percentiles_df %>%
      filter(last_first == input$batter1) %>%
      select(ends_with("_pct")) %>%
      unlist(use.names = FALSE)
    names(p1_percentiles) <- stats
    
    p2_percentiles <- percentiles_df %>%
      filter(last_first == input$batter2) %>%
      select(ends_with("_pct")) %>%
      unlist(use.names = FALSE)
    names(p2_percentiles) <- stats
    
    score1 <- sum(p1_percentiles * batter_score_weights[stats], na.rm = TRUE)
    score2 <- sum(p2_percentiles * batter_score_weights[stats], na.rm = TRUE)
    
    list(
      p1 = p1,
      p2 = p2,
      p1_percentiles = p1_percentiles,
      p2_percentiles = p2_percentiles,
      score1 = score1,
      score2 = score2
    )
  })
  
  output$plot1 <- renderPlot({
    data <- calculate_scores()
    color1 <- if (data$score1 > data$score2) "limegreen" else "red"
    draw_profile_card(data$p1, data$p1_percentiles, data$p2_percentiles, color1)
  })
  
  output$plot2 <- renderPlot({
    data <- calculate_scores()
    color2 <- if (data$score2 > data$score1) "limegreen" else "red"
    draw_profile_card(data$p2, data$p2_percentiles, data$p1_percentiles, color2)
  })
  
  output$preferredBatter <- renderText({
    data <- calculate_scores()
    preferred <- if (data$score1 > data$score2) input$batter1 else input$batter2
    paste("Preferred Batter:", preferred)
  })
  
  output$scoreDifference <- renderText({
    data <- calculate_scores()
    diff <- abs(data$score1 - data$score2)
    paste("Score Difference:", round(diff, 1))
  })
}

shinyApp(ui = ui, server = server)

