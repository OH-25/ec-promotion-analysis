# PROMOTION SPEED ANALYSIS (SC,AST.AD) 2015-2025


library(dplyr)
library(tidyr)
library(stringr)

# (1) Long format with parsed grades

names(promos)[1] <- "person"

data_long <- promos |>
  pivot_longer(
    cols = -person,
    names_to  = "year",
    values_to = "grade",
    values_drop_na = TRUE
  ) |>
  mutate(
    year      = as.integer(year),
    category  = str_extract(grade, "^[A-Z]+"),   # SC / AST / AD
    grade_num = as.integer(str_extract(grade, "\\d+"))
  ) |>
  arrange(person, year)

# (2) Reduction to persons with at least 2 promotions

data_long <- data_long |>
  group_by(person) |>
  filter(n() >= 2L) |>
  ungroup()

# (3) Build consecutive promotion intervals

promotions_raw <- data_long |>
  group_by(person) |>
  arrange(year, .by_group = TRUE) |>
  mutate(
    next_year      = dplyr::lead(year),
    next_grade_num = dplyr::lead(grade_num),
    next_category  = dplyr::lead(category)
  ) |>
  ungroup() |>
  filter(
    !is.na(next_year),
    next_category == category,     # exclusion of category jumps
    next_grade_num > grade_num     # only positive promotions
  )

# (4) Treating jumps over several grades

promotions_expanded <- promotions_raw |>
  mutate(
    steps        = next_grade_num - grade_num,
    weight       = 1 / steps,
    wait_total   = next_year - year,
    wait_perstep = wait_total / steps
  ) |>
  tidyr::uncount(steps, .remove = FALSE, .id = "step_index") |>
  mutate(
    from_grade_num = grade_num + step_index - 1L,
    to_grade_num   = grade_num + step_index,
    wait_years     = wait_perstep
  )

# (5) Calculating average waiting time for promotion

results <- promotions_expanded |>
  group_by(category, from_grade_num, to_grade_num) |>
  summarise(
    n_effective_persons = sum(weight),
    avg_wait_years      = sum(wait_years * weight) / n_effective_persons,
    .groups = "drop"
  ) |>
  mutate(
    from_grade = paste0(category, from_grade_num),
    to_grade   = paste0(category, to_grade_num),
    # rounding
    n_effective_persons = round(n_effective_persons, 2),
    avg_wait_years      = round(avg_wait_years, 2)
  ) |>
  arrange(category, from_grade_num) |>
  # keep only desired columns in desired order
  select(
    category,
    from_grade,
    to_grade,
    avg_wait_years,
    n_effective_persons
  )

# (6) Displaying results

results

# View(results) to show spreadsheet view