# Import packages
library(dplyr)
library(AER)
library(knitr)
library(kableExtra)

# Import 1980 IPUMS USA census data
df <- read.csv("data/ipums_1980_angrist.csv")

# Rename variables and select relevant columns
column_names <- c(
  "mom_weeks_worked" = "weeksm",
  "mom_hours_worked" = "hoursm",
  "mom_labor_income" = "income1m",
  "mom_self_employment_income" = "income2m",
  "dad_weeks_worked" = "weeksd",
  "dad_hours_worked" = "hoursd",
  "dad_labor_income" = "income1d",
  "dad_self_employment_income" = "income2d",
  "age_oldest_child_quarters" = "ageqk",
  "age_second_child_quarters" = "ageq2nd",
  "age_third_child_quarters" = "ageq3rd",
  "age_fourth_child_quarters" = "ageq4th",
  "age_fifth_child_quarters" = "ageq5th",
  "mom_age" = "agem",
  "mom_year_birth" = "yobm",
  "mom_quarter_birth" = "qtrbthm",
  "quarter_birth_oldest_child" = "qtrbkid",
  "mom_race" = "racem",
  "first_born_sex" = "sexk",
  "second_born_sex" = "sex2nd",
  "num_children" = "kidcount",
  "mom_age_married" = "agemar",
  "mom_quarter_married" = "qtrmar",
  "dad_age" = "aged",
  "dad_quarter_birth" = "qtrbthd",
  "number_of_times_married" = "timesmar",
  "marital_status" = "marital",
  "family_income" = "faminc"
)

df <- df %>% rename(!!!column_names)
df <- df %>% select(all_of(names(column_names)))

df$mom_age_married <- ifelse(df$mom_age_married == 0, NA, df$mom_age_married) # Replace 0 with NA

# Adjust 'mom_quarter_married' variable to remove the 1-indexing and replace 0 with NA
df$mom_quarter_married <- ifelse(df$mom_quarter_married == 0, NA, df$mom_quarter_married) - 1

# Adjust 'quarter_birth' variables to remove the 1-indexing
df$mom_quarter_birth <- df$mom_quarter_birth - 1
df$dad_quarter_birth <- df$dad_quarter_birth - 1
df$mom_year_birth <- 1980 - df$mom_age

# Compute 'year_married' based on timing of marriage and birth
df$year_married <- df$mom_year_birth + df$mom_age_married + as.integer(df$mom_quarter_birth > df$mom_quarter_married)
df$year_quarter_married <- df$year_married + (df$mom_quarter_married / 4)
df$mom_age_first_birth <- df$mom_age - (df$age_oldest_child_quarters / 4)
df$year_oldest_child_birth <- df$mom_year_birth + df$mom_age_first_birth
df$quarter_birth_oldest_child <- df$quarter_birth_oldest_child -1  # Adjust for indexing
df$year_quarter_birth <- df$year_oldest_child_birth + (df$quarter_birth_oldest_child / 4)
df$unmarried_birth <- as.integer(df$year_quarter_married > df$year_quarter_birth)

# Race indicators
df$mom_black <- as.integer(df$mom_race == 2)
df$mom_hispanic <- as.integer(df$mom_race == 12)
df$mom_white <- as.integer(df$mom_race == 1)
df$mom_other_race <- 1 - df$mom_black - df$mom_hispanic - df$mom_white

# Compute father's year of birth and age at first birth
df$dad_year_birth <- 79 - df$dad_age
df$dad_year_birth <- ifelse(df$dad_quarter_birth == 0, 80 - df$dad_age, df$dad_year_birth)
df$dad_age_quarters <- (4 * (80 - df$dad_year_birth)) - df$dad_quarter_birth
df$dad_age_first_birth <- (df$dad_age_quarters - df$age_oldest_child_quarters) %/% 4

# Children data indicators
df$first_born_boy <- as.integer(df$first_born_sex == 0)
df$second_born_boy <- as.integer(df$second_born_sex == 0)
df$both_boys <- as.integer((df$first_born_sex == 0) & (df$second_born_sex == 0))
df$both_girls <- as.integer((df$first_born_sex == 1) & (df$second_born_sex == 1))
df$same_sex <- as.integer(df$both_boys | df$both_girls)
df$more_than_two_children <- as.integer(df$num_children > 2)

# In labor force indicators
df$mom_worked_indicator <- as.integer(df$mom_weeks_worked > 0)
df$dad_worked_indicator <- as.integer(df$dad_weeks_worked > 0)

cpi_adjustment <-  1.85 # CPI adjustment factor from 1980 to 1995
df$mom_labor_income <- df$mom_labor_income * cpi_adjustment
df$dad_labor_income <- df$dad_labor_income * cpi_adjustment

df$constant <- 1

df <- df %>% filter(
  (mom_age >= 21) &
  (mom_age <= 35) &
  (num_children >= 2) &
  (age_second_child_quarters > 4) &
  (mom_age_first_birth >= 15)
)

df_married <- df %>% filter(
  !is.na(dad_age) &
  (number_of_times_married == 1) &
  (marital_status == 0) &
  (unmarried_birth == 0) &
  (dad_age_first_birth >= 15) &
  (mom_age_first_birth >= 15)
)

mom_outcomes <- c(
  "mom_weeks_worked",
  "mom_hours_worked",
  "mom_labor_income",
  "mom_worked_indicator"
)

dad_outcomes <- c(
  "dad_weeks_worked",
  "dad_hours_worked",
  "dad_labor_income",
  "dad_worked_indicator"
)

covariates <- c(
  "mom_age",
  "mom_age_first_birth",
  "mom_black",
  "mom_hispanic",
  "mom_other_race",
  "first_born_boy",
  "second_born_boy",
  "constant"
)

instrument <- "same_sex"
instrumented <- "more_than_two_children"
outcome_labels <- c("Weeks Worked per Year", "Hours Worked per Week", "Labor Income", "Worked for Pay")

# Function to format estimates with significance stars
format_estimates <- function(model, param) {
  est <- coef(model)[param]
  se <- sqrt(diag(vcov(model)))[param]
  t_stat <- est / se
  pval <- 2 * pt(-abs(t_stat), df = df.residual(model))
  
  # Assign significance stars
  stars <- ifelse(pval < 0.001, "***",
                  ifelse(pval < 0.01, "**",
                         ifelse(pval < 0.05, "*", "")))
  
  formatted_estimate <- paste0(sprintf("%.2f", est), stars, "\n(", sprintf("%.2f", se), ")")
  return(formatted_estimate)
}

# Function to run IV regressions and collect formatted results
run_iv_regressions <- function(data, outcomes, covariates, instrumented, instrument){
  results <- c()
  for (outcome in outcomes){
    vars_needed <- c(outcome, covariates, instrumented, instrument)
    df_reg <- data %>% select(all_of(vars_needed)) %>% na.omit()
    
    formula_iv <- as.formula(paste(outcome, "~", paste(c(covariates, instrumented), collapse = " + "),
                                   "|", paste(c(covariates, instrument), collapse = " + ")))
    model <- ivreg(formula_iv, data = df_reg)
    
    formatted_estimate <- format_estimates(model, instrumented)
    results <- c(results, formatted_estimate)
  }
  return(results)
}

# Run regressions and collect results
results_all_women <- run_iv_regressions(df, mom_outcomes, covariates, instrumented, instrument)
results_married_women <- run_iv_regressions(df_married, mom_outcomes, covariates, instrumented, instrument)
results_husbands <- run_iv_regressions(df_married, dad_outcomes, covariates, instrumented, instrument)

# Create summary table
summary_table <- data.frame(
  Outcome = outcome_labels,
  `All Women` = results_all_women,
  `Married Women` = results_married_women,
  Husbands = results_husbands,
  stringsAsFactors = FALSE
)

# Save the table
kable(summary_table, format = "latex", booktabs = TRUE) %>%
  save_kable("iv_results.tex")
kable(summary_table, format = "html") %>%
  kable_styling() %>%
  save_kable("iv_results.html")
