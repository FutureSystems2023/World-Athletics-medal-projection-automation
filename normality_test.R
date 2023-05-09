
library(conflicted)
library(tidyverse)
library(ggplot2)
library(readxl)
library(chron)
library(lubridate)
library(optparse)

conflicts_prefer(dplyr::filter)

option_list = list(
  make_option(c("-f", "--file"), type = "character", default = NULL, help = "target excel file name", metavar = "character"),
  make_option(c("-c", "--compileOutput"), action = "store_true", default = NULL, help = "Compile output into Completed folder with its respective subfolder")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

# Check if target excel file name was supplied, if not use wildcard excel file.
if (is.null(opt$file)) {
  tryCatch({
    targetFile = list.files(pattern = "\\.xlsx$")[1]
    print(paste("No target file name specified.", targetFile, "will be used as target excel file..."))
  }, error = function(err) {
    print(err)
    quit()
  })
} else {
  targetFile = opt$file
}

# Read Excel from filepath and assign to dataframe object variables
filePath <- targetFile
print(paste("Target Excel file is:", filePath))
athlete_data_2019to2023 <- read_excel(filePath, sheet = "Competitors 2019-2023")
athlete_data_2022to2023 <- read_excel(filePath, sheet = "Competitors 2022-2023")
athlete_data_2023 <- read_excel(filePath, sheet = "Competitors 2023")
print("Commencing automated normality tests on data...")


# Create 2 Empty DataFrames, 1 with columns (Shapiro Wilk test) and 1 for compiling the different datasets used
columns = c("Name", "Shapiro-Wilks_p-value", "Dataset_Used", "Total_Datapoints", "Datapoints_Used", "Remarks")
df_shapiroTestResults = data.frame(matrix(nrow = 0, ncol = length(columns)))
colnames(df_shapiroTestResults) = columns
df_results = data.frame()


# Filter Unqiue Athlete, Loop through each Athlete and perform Shapiro Wilk' s Test
UniqueAthletes <- unique(athlete_data_2019to2023$athlete_name)
for (i in 1:length(UniqueAthletes)) {
  print(UniqueAthletes[i])
  dataset_used <- "2023"
  remarks <- ""
  results <- filter(athlete_data_2023, athlete_name == UniqueAthletes[i])
  top50pctResultsRows <- ceiling(nrow(results) / 2)
  Athlete <- head(results, top50pctResultsRows)

  # Conditional Checks for Count of Dataframe Object. If less than 5, escalate to next dataset.
  if (nrow(Athlete) < 3) {
    dataset_used <- "2022-2023"
    remarks <- paste("Not enough data points for 2023 (total of ", nrow(Athlete), " datapts)")
    results <- filter(athlete_data_2022to2023, athlete_name == UniqueAthletes[i])
    top50pctResultsRows <- ceiling(nrow(results) / 2)
    Athlete <- head(results, top50pctResultsRows)
  }

  if (nrow(Athlete) < 3) {
    dataset_used <- "2019-2023"
    remarks <- paste("Not enough data points for 2022-2023 (total of ", nrow(Athlete), " datapts)")
    results <- filter(athlete_data_2019to2023, athlete_name == UniqueAthletes[i])
    top50pctResultsRows <- ceiling(nrow(results) / 2)
    Athlete <- head(results, top50pctResultsRows)
  }

  if (nrow(Athlete) < 3) {
    remarks <- paste("Not enough data points for 2019-2023 (total of ", nrow(Athlete), " datapts)")

    # Append Athlete normality result to dataframe
    df_shapiroTestResults[nrow(df_shapiroTestResults) + 1,] = c(UniqueAthletes[i], "NA", dataset_used, nrow(results), top50pctResultsRows, remarks)

    # Append Athlete dataset to dataframe
    df_results = rbind(df_results, Athlete)
    next
  }

  if (sum(!duplicated(Athlete$mark)) == 1) {
    remarks <- paste("Athlete has same data for all available datapoints, please manually run normality test. (total of ", nrow(Athlete), " datapts)")
    df_shapiroTestResults[nrow(df_shapiroTestResults) + 1,] = c(UniqueAthletes[i], "NA", dataset_used, nrow(results), top50pctResultsRows, remarks)
    df_results = rbind(df_results, Athlete)
    next
  } else {
    shap_test = shapiro.test(Athlete$mark)
  }

  # Conditional Checks for Shapiro Wilk Normality test of Dataframe Object. If less than 0.05, escalate to next dataset.
  if (shap_test$p.value < 0.05 && dataset_used != "2019-2023") {
    dataset_used <- "2022-2023"
    remarks <- paste("Shapiro Wilk not normal for 2023 (p-value = ", shap_test$p.value, ")")
    results <- filter(athlete_data_2022to2023, athlete_name == UniqueAthletes[i])
    top50pctResultsRows <- ceiling(nrow(results) / 2)
    Athlete <- head(filter(athlete_data_2022to2023, athlete_name == UniqueAthletes[i]), top50pctResultsRows)
    Athlete$mark <- period_to_seconds(ms(Athlete$mark))
    if (sum(!duplicated(Athlete$mark)) == 1) {
      remarks <- paste("Athlete has same data for all available datapoints, please manually run normality test. (total of ", nrow(Athlete), " datapts)")
      df_shapiroTestResults[nrow(df_shapiroTestResults) + 1,] = c(UniqueAthletes[i], "NA", dataset_used, nrow(results), top50pctResultsRows, remarks)
      df_results = rbind(df_results, Athlete)
      next
    } else {
      shap_test = shapiro.test(Athlete$mark)
    }
  }

  if (shap_test$p.value < 0.05) {
    dataset_used <- "2019-2023"
    remarks <- paste("Shapiro Wilk not normal for 2022-2023 (p-value = ", shap_test$p.value, ")")
    results <- filter(athlete_data_2019to2023, athlete_name == UniqueAthletes[i])
    top50pctResultsRows <- ceiling(nrow(results) / 2)
    Athlete <- head(filter(athlete_data_2019to2023, athlete_name == UniqueAthletes[i]), top50pctResultsRows)
    Athlete$mark <- period_to_seconds(ms(Athlete$mark))
    if (sum(!duplicated(Athlete$mark)) == 1) {
      remarks <- paste("Athlete has same data for all available datapoints, please manually run normality test. (total of ", nrow(Athlete), " datapts)")
      df_shapiroTestResults[nrow(df_shapiroTestResults) + 1,] = c(UniqueAthletes[i], "NA", dataset_used, nrow(results), top50pctResultsRows, remarks)
      df_results = rbind(df_results, Athlete)
      next
    } else {
      shap_test = shapiro.test(Athlete$mark)
    }
  }

  if (shap_test$p.value < 0.05) {
    remarks <- paste("Shapiro Wilk not normal for 2019-2023 (p-value = ", shap_test$p.value, ")")
  }


  # Append Athlete normality result to dataframe
  df_shapiroTestResults[nrow(df_shapiroTestResults) + 1,] = c(UniqueAthletes[i], shap_test$p.value, dataset_used, nrow(results), top50pctResultsRows, remarks)
  print(paste("Final Shapiro wilk p-value:", shap_test$p.value, ". Dataset Used:", dataset_used))

  # Append Athlete dataset to dataframe
  df_results = rbind(df_results, Athlete)
}

# Write out analysis to csvs (one for shaprio test results, one for the dataset used)
write.csv(df_shapiroTestResults, "shapiroTest.csv", row.names = FALSE)
write.csv(df_results, "dataset.csv", row.names = FALSE)


# Move Files function
my.file.rename <- function(from, to) {
  todir <- dirname(to)
  if (!isTRUE(file.info(todir)$isdir)) dir.create(todir, recursive = TRUE)
  file.rename(from = from, to = to)
}


# Move Files to Completed and create subfolder based on target excel file name
if (!is.null(opt$compileOutput)) {
  print(paste("Moving Files to './Completed/", substr(filePath, 1, nchar(filePath) - 5), "'...", sep = ""))
  if (!file.exists("./Completed")) {
    dir.create("./Completed")
  }
  file.copy(from = "./shapiroTest.csv", to = paste("./Completed/", substr(filePath, 1, nchar(filePath) - 5), " shapiroTest.csv", sep = ""))
  my.file.rename(from = "./shapiroTest.csv",
               to = paste("./Completed/", substr(filePath, 1, nchar(filePath) - 5), "/shapiroTest.csv", sep = ""))
  my.file.rename(from = "./dataset.csv",
               to = paste("./Completed/", substr(filePath, 1, nchar(filePath) - 5), "/dataset.csv", sep = ""))
  my.file.rename(from = filePath,
               to = paste("./Completed/", substr(filePath, 1, nchar(filePath) - 5), "/", filePath, sep = ""))
}


print("R script ran successfully!")