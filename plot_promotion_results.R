library(dplyr)
library(stringr)
library(ggplot2)

results_plot <- results |>
  mutate(
    from_num     = as.integer(str_extract(from_grade, "\\d+")),
    to_num       = as.integer(str_extract(to_grade, "\\d+")),
    change_label = paste0(from_num, "-", to_num)
  )


plot_category <- function(cat_label) {
  df <- results_plot |>
    filter(category == cat_label) |>
    arrange(from_num, to_num) |>
    mutate(
      change_label = factor(change_label, levels = unique(change_label))
    )
  
  if (nrow(df) == 0) {
    stop(paste("No data for category", cat_label))
  }
  
  # scale factor to align ranges
  scale_factor <- max(df$n_effective_persons, na.rm = TRUE) /
    max(df$avg_wait_years,      na.rm = TRUE)
  
  ggplot(df, aes(x = change_label)) +
    # bars: persons (right axis, scaled)
    geom_col(
      aes(y = n_effective_persons / scale_factor, fill = "Effective number of persons"),
      alpha = 0.4
    ) +
    # line + points: years (left axis)
    geom_line(
      aes(y = avg_wait_years, group = 1, color = "Average waiting time (years)"),
      linewidth = 1
    ) +
    geom_point(
      aes(y = avg_wait_years, color = "Average waiting time (years)"),
      size = 2
    ) +
    scale_y_continuous(
      name = "Average waiting time (years)",
      sec.axis = sec_axis(
        ~ . * scale_factor,
        name = "Effective number of persons"
      )
    ) +
    scale_fill_manual(
      name = "",
      values = "blue"
    ) +
    scale_color_manual(
      name = "",
      values = "green"
    ) +
    labs(
      x = "Grade change",
      title = paste("Promotions in", cat_label, "career")
    ) +
    theme_minimal() +
    theme(
      legend.position = "bottom"
    )
}

plot_SC  <- plot_category("SC")
plot_AST <- plot_category("AST")
plot_AD  <- plot_category("AD")


