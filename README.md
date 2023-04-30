# **Documentation**

This R script is to automate the processes of medal projection for World Athletics results collected after running <a href="https://github.com/FSonline23/World-Athletics-data-collection">World-Athletics-data-collection/script.py</a>. 2 CSVs will be outputed (1 for the results of Shapiro Wilk's normality tests, 1 for compiling the datasets to be used for simulation)

<hr>

## **Requirements (Installation)**

Change into current directory and run R install.packages() to install the required packages using the following command.

<pre><code>install.packages(c("tidyverse", "ggplot2", "readxl", "chron", "lubridate"))</code></pre>
<hr>

## **Running the Script**

Ensure that R is installed and added to environment path before proceeding. In your terminal or your preferred CLI, Change into directory of normality_test.R script and run the following command.

<pre><code>Rscript normality_test.R</code></pre>
<hr>

## **What does the Script do?**

The script retrieves the data from "ALL_COUNTRIES" worksheet in the target excel workbook. Results will be extracted based on the name of athletes (namelist.csv) and discipline arguments supplied.
