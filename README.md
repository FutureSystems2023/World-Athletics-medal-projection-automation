# **Documentation**

This R script is to automate the processes of medal projection for FINA results collected after running <a href="https://github.com/FSonline23/FINA-data-collection">FINA-data-collection/script.py</a>. 2 CSVs will be outputed (1 for the results of Shapiro Wilk's normality tests, 1 for compiling the datasets to be used for simulation)

<hr>

## **Requirements (Installation)**

Change into current directory and run R install.packages() to install the required packages using the following command.

<pre><code>install.packages(c("tidyverse", "ggplot2", "readxl", "chron", "lubridate"))</code></pre>
<hr>

## **Running the Script**

Ensure that R is installed and added to environment path before proceeding. In your terminal or your preferred CLI, Change into directory of normality_test.R script and run the following command.

<pre><code>Rscript normality_test.R</code></pre>
