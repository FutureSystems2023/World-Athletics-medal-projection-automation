# **Documentation**

This R script is to automate the processes of medal projection for World Athletics results collected after running <a href="https://github.com/FSonline23/World-Athletics-data-collection">World-Athletics-data-collection/script.py</a>. 2 CSVs will be outputed (1 for the results of Shapiro Wilk's normality tests, 1 for compiling the datasets to be used for simulation)

<hr>

## **Requirements (Installation)**

Open up R console. Change into current directory and run R install.packages() to install the required packages using the following command.

<pre><code>install.packages(c("tidyverse", "ggplot2", "readxl", "chron", "lubridate"))</code></pre>
<hr>

## **Running the Script**

Ensure that R is installed and added to environment path before proceeding. In your terminal or your preferred CLI, Change into directory of normality_test.R script and run the following command.

<pre><code>Rscript normality_test.R</code></pre>
<hr>

## **What does the Script do?**

The script retrieves the data from the different worksheets (Competitors 2019-2023, Competitors 2022-2023 & Competitors 2023) in finalFilteredCleanedResults.xlsx created by scrapping <a href="https://github.com/FSonline23/World-Athletics-data-collection/blob/main/script.py">python script</a>.

Using dplyr library, shapiro wilk test will be conducted on the each unique athletes from the data. 2 CSVs will be outputed after running of script. One of the CSVs contains the results of the statistical test while the other contains the particular dataset (by year) that was used to test for the athletes. The reason for the dataset used will be explained in the [remarks] column.

<blockquote>For example, if 2019-2023 dataset used to test for Athlete A, remarks will specify that data points of Athlete A is insufficient for 2022-2023 (datapts < 5).</blockquote>

<br/>

Do note that if shapiro wilk is significant, the next dataset will be used.

<blockquote>For example, normality test 2022-2023 dataset is significant (p-value <= 0.05, displaying non-normality). Then, 2019-2023 dataset will be used to test for Athlete A. Remarks will specify that p-value of Athlete A is significant for 2022-2023.</blockquote>

<br/>
