###########################################################################################################
## Main functions used to study the maturity metrics involving the ecosystem dimension
##  
## Dependencies:
##  - database.R
##  - utils.R
##
## License: 
##   Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
##   (https://creativecommons.org/licenses/by-sa/4.0/)
###########################################################################################################

###########################################################################################################
## INIT (execute these steps always)
###########################################################################################################

# setting random seed
set.seed(123)

# cleaning memory
rm(list=ls())

# setting input/output folders (to be configured if required)
inputPath <- getwd()
utilsPath <- getwd()
outputPath <- getwd()

# Setting the extension of the file to be exported
extension <- ".pdf"

# Importing utils
setwd(utilsPath)
source("database.R")
setwd(utilsPath)
source("utils.R")

# PROJECTS
ecosystem <- getEcosystem()

#############################
## BOXPLOTS FOR THE PAPER
#############################

# Activity
data <- ecosystem
data <- data[! is.na(data$eco_avg_commits_developer),]
title <- "Average number of commits per developer"
filename <- "eco_avg_commits_developer"
drawBoxplot(data, data$mde, data$eco_avg_commits_developer, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_avg_commits_developer, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$eco_num_commits),]
title <- "Total number of commits"
filename <- "eco_num_commits"
drawBoxplot(data, data$mde, data$eco_num_commits, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_num_commits, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$eco_num_contributors),]
title <- "Total number of contributors"
filename <- "eco_num_contributors"
drawBoxplot(data, data$mde, data$eco_num_contributors, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_num_contributors, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$eco_avg_commits_month),]
title <- "Average number of commits per month"
filename <- "eco_avg_commits_month"
drawBoxplot(data, data$mde, data$eco_avg_commits_month, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_avg_commits_month, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$eco_avg_commits_week),]
title <- "Average number of commits per week"
filename <- "eco_avg_commits_week"
drawBoxplot(data, data$mde, data$eco_avg_commits_week, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_avg_commits_week, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$eco_avg_commits_last_year),]
title <- "Average Number of commits last year"
filename <- "eco_avg_commits_last_year"
drawBoxplot(data, data$mde, data$eco_avg_commits_last_year, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_avg_commits_last_year, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

# diversity
# For the paper
data <- ecosystem
data <- data[! is.na(data$eco_ratio_outsiders),]
title <- "Ratio of outsiders"
filename <- "eco_ratio_outsiders"
drawBoxplot(data, data$mde, data$eco_ratio_outsiders, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_ratio_outsiders, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$eco_ratio_commits_top_committers),]
title <- "Ratio of commits from Top 3 committers"
filename <- "eco_ratio_commits_top_committers"
drawBoxplot(data, data$mde, data$eco_ratio_commits_top_committers, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_ratio_commits_top_committers, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$eco_ratio_casuals),]
title <- "Ratio casuals"
filename <- "eco_ratio_casuals"
drawBoxplot(data, data$mde, data$eco_ratio_casuals, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$eco_ratio_casuals, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)


