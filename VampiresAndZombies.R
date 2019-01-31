library(progress)

members <- read.csv('~/R/ValidateHealth/members.csv')
conditions <- read.csv('~/R/ValidateHealth/conditions.csv')

# calculates vampire score
vampire_score <- function(has_condition_1, has_condition_2) {
  score <- 1.5
  if (has_condition_1) {
    score <- score + 2
  }
  if (has_condition_2) {
    score <- score + 5
  }
  if (has_condition_1 & has_condition_2) {
    score <- score + 3
  }
  return(score)
}

#calculates zombie score
zombie_score <- function(has_condition_1, has_condition_2) {
  score <- 1
  if (has_condition_1) {
    score <- score + 2
  }
  if (has_condition_2) {
    score <- score + 3
  }
  return(score)
}

setup_data <- function(members, conditions) {
  aux <- conditions
  # Use numbers to identify conditions and vampires
  aux$is_vampire <- aux$prev_dx %in% c(268.9, 172.9)
  aux$condition_1 <- aux$prev_dx %in% c(268.9, 897.2)
  aux$condition_2 <- aux$prev_dx %in% c(172.9, 897.6)
  
  # Long to wide aggregation (using aggregation of booleans)
  subset <-  aux[, c("ID", "is_vampire", "condition_1", "condition_2")]
  aggr <- aggregate(subset, by = list(subset$ID), FUN = sum)
  aggr <- aggr[, !(colnames(aggr) %in% c("Group.1"))]
  
  # Recoding of boolean values
  # (Greater than 1 should be impossible)
  aggr$is_vampire <- aggr$is_vampire == 1
  aggr$condition_1 <- aggr$condition_1 == 1
  aggr$condition_2 <- aggr$condition_2 == 1
  
  # Left-join between aggregate condtions and members
  data <- merge(aggr, members, all.x = TRUE, all.y = FALSE)
  data <- data[,  !(colnames(data) %in% c("v_flag"))]
  data <- data[complete.cases(data), ]
  
  return(data)
}

score_row <- function(i, data, pb) {
  row <- data[i, ]
  pb$tick()
  if (row$is_vampire) {
    return(vampire_score(row$condition_1, row$condition_2))
  } else {
    return(zombie_score(row$condition_1, row$condition_2))
  }
}

add_current_algorithm_score <- function(data) {
  pb <- progress_bar$new(
    format = ":percent in :elapsed, ETA :eta, at :tick_rate/sec",
    total = nrow(data), clear = FALSE, width= 60
  )
  data$cur_score <- unlist(lapply(1:nrow(data), score_row, data, pb))
  return(data)
}

add_new_algorithm_score <- function(data) {
  model <- lm(
    act_cost ~ is_vampire + condition_1 + condition_2,
    data = data
  )
  data$new_score <- predict(model) / 10000
  return(data)
}

#
# 20.
#

data <- setup_data(members, conditions)
data <- add_current_algorithm_score(data)

write.csv(
  data[, c("ID", "cur_score")],
  file = '~/R/ValidateHealth/current_scores.csv',
  row.names = FALSE
)


#
# 21.
#

data$current_expected <- data$cur_score * 10000
data$current_error <- data$act_cost - data$current_expected

summary(data$current_error)


#
# 22.
#
# Explanation:
# Insurers in the system consistently pay less than expected: mean of about $20,000
#

#
# 23.
#
# Explanation:
# Applies a linear regression model detailed in add_new_algorithm_score function.
# Summary of model is as follows:
# Call:
#   lm(formula = act_cost ~ is_vampire + condition_1 + condition_2, 
#      data = data)
# 
# Residuals:
#   Min     1Q Median     3Q    Max 
# -30942  -5114   -201   3360 111476 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)      20066.43      36.94   543.2   <2e-16 ***
#   is_vampireTRUE  -15009.92      18.47  -812.6   <2e-16 ***
#   condition_1TRUE   2462.80      30.63    80.4   <2e-16 ***
#   condition_2TRUE  17367.96      30.63   567.0   <2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 8261 on 899996 degrees of freedom
# Multiple R-squared:  0.6547,	Adjusted R-squared:  0.6547 
# F-statistic: 5.689e+05 on 3 and 899996 DF,  p-value: < 2.2e-16
#
# Summary of new error term is as follows:
# > summary(data$new_error)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# -30942   -5114    -201       0    3360  111476 



data <- add_new_algorithm_score(data)

data$new_expected <- data$new_score * 10000
data$new_error <- data$act_cost - data$new_expected

summary(data$new_error)

write.csv(
  data[, c("ID", "new_score")],
  file = '~/R/ValidateHealth/new_scores.csv',
  row.names = FALSE
)
