
library(conflicted)
library(tidyverse)
library(ggplot2)
library(readxl)
library(chron)
library(lubridate)

conflicts_prefer(dplyr::filter)

# Read Excel from filepath and assign to dataframe object variables
filePath <- "F 200 Freestyle.xlsx"
athlete_data_2019to2023 <- read_excel(filePath, sheet = "Competitors 2019-2023")
athlete_data_2022to2023 <- read_excel(filePath, sheet = "Competitors 2022-2023")
athlete_data_2023 <- read_excel(filePath, sheet = "Competitors 2023")

# Create 2 Empty DataFrames, 1 with columns (Shapiro Wilk test) and 1 for compiling the different datasets used
columns = c("Name", "Shapiro-Wilks_p-value", "Dataset_Used", "Total_Datapoints", "Datapoints_Used", "Remarks")
df_shapiroTestResults = data.frame(matrix(nrow = 0, ncol = length(columns)))
colnames(df_shapiroTestResults) = columns
df_results = data.frame()

# Filter Unqiue Athlete, Loop through each Athlete and perform Shapiro Wilk's Test
UniqueAthlete <- unique(athlete_data_2019to2023$full_name_computed)
for (i in 1:length(UniqueAthlete)) {
  print(UniqueAthlete[i])
  dataset_used <- "2023"
  remarks <- ""
  results <- filter(athlete_data_2023, full_name_computed == UniqueAthlete[i])
  top50pctResultsRows <- ceiling(nrow(results) / 2)
  Athlete <- head(results, top50pctResultsRows)

  # Conditional Checks for Count of Dataframe Object. If less than 5, escalate to next dataset.
  if (nrow(Athlete) < 3) {
    dataset_used <- "2022-2023"
    remarks <- paste("Not enough data points for 2023 (total of ", nrow(Athlete), " datapts)")
    results <- filter(athlete_data_2022to2023, full_name_computed == UniqueAthlete[i])
    top50pctResultsRows <- ceiling(nrow(results) / 2)
    Athlete <- head(results, top50pctResultsRows)
  }

  if (nrow(Athlete) < 3) {
    dataset_used <- "2019-2023"
    remarks <- paste("Not enough data points for 2022-2023 (total of ", nrow(Athlete), " datapts)")
    results <- filter(athlete_data_2019to2023, full_name_computed == UniqueAthlete[i])
    top50pctResultsRows <- ceiling(nrow(results) / 2)
    Athlete <- head(results, top50pctResultsRows)
  }

  if (nrow(Athlete) < 3) {
    remarks <- paste("Not enough data points for 2019-2023 (total of ", nrow(Athlete), " datapts)")

    # Append Athlete normality result to dataframe
    df_shapiroTestResults[nrow(df_shapiroTestResults) + 1,] = c(UniqueAthlete[i], "NA", dataset_used, nrow(results), top50pctResultsRows, remarks)
    # print(paste("Final Shapiro wilk p-value: NA. Dataset Used:", dataset_used))

    # Append Athlete dataset to dataframe
    df_results = rbind(df_results, Athlete)
    next
  }

  Athlete$swim_time <- period_to_seconds(ms(Athlete$swim_time))
  shap_test = shapiro.test(Athlete$swim_time)

  # Conditional Checks for Shapiro Wilk Normality test of Dataframe Object. If less than 0.05, escalate to next dataset.
  if (shap_test$p.value < 0.05) {
    dataset_used <- "2022-2023"
    remarks <- paste("Shapiro Wilk not normal for 2023 (p-value = ", shap_test$p.value, ")")
    # print("Shapiro-wilk test lesser than 0.05, trying 2022 to 2023 dataset")
    top50pctResultsRows <- round(nrow(Athlete) / 2, digits = 0)
    Athlete <- head(filter(athlete_data_2022to2023, full_name_computed == UniqueAthlete[i]), top50pctResultsRows)
    Athlete$swim_time <- period_to_seconds(ms(Athlete$swim_time))
    shap_test = shapiro.test(Athlete$swim_time)
    # print(shap_test$p.value)
  }

  if (shap_test$p.value < 0.05) {
    dataset_used <- "2019-2023"
    remarks <- paste("Shapiro Wilk not normal for 2022-2023 (p-value = ", shap_test$p.value, ")")
    # print("Shapiro-wilk test lesser than 0.05, trying 2019 to 2023 dataset")
    top50pctResultsRows <- round(nrow(Athlete) / 2, digits = 0)
    Athlete <- head(filter(athlete_data_2019to2023, full_name_computed == UniqueAthlete[i]), top50pctResultsRows)
    Athlete$swim_time <- period_to_seconds(ms(Athlete$swim_time))
    shap_test = shapiro.test(Athlete$swim_time)
    # print(shap_test$p.value)
  }

  if (shap_test$p.value < 0.05) {
    remarks <- paste("Shapiro Wilk not normal for 2019-2023 (p-value = ", shap_test$p.value, ")")
  }

  # Append Athlete normality result to dataframe
  df_shapiroTestResults[nrow(df_shapiroTestResults) + 1,] = c(UniqueAthlete[i], shap_test$p.value, dataset_used, nrow(results), top50pctResultsRows, remarks)
  print(paste("Final Shapiro wilk p-value:", shap_test$p.value, ". Dataset Used:", dataset_used))

  # Append Athlete dataset to dataframe
  df_results = rbind(df_results, Athlete)
}

# print(df_shapiroTestResults)

write.csv(df_shapiroTestResults, "shapiroTest.csv", row.names = FALSE)
write.csv(df_results, "dataset.csv", row.names = FALSE)