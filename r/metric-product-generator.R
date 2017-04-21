###########################################################################################################
## Main functions used to study the maturity metrics involving the product dimension
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
product <- getProduct()

#############################
## BOXPLOTS FOR THE PAPER
#############################

# Analyzability
data <- product
data <- data[! is.na(data$prod_lines_code),]
title <- "Lines of code"
filename <- "prod_lines_code"
drawBoxplot(data, data$mde, data$prod_lines_code, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_lines_code, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

data <- product
data <- data[! is.na(data$prod_num_extensions),]
title <- "Number of file extensions"
filename <- "prod_num_extensions"
drawBoxplot(data, data$mde, data$prod_num_extensions, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_num_extensions, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

data <- product
data <- data[! is.na(data$prod_class_complexity),]
title <- "Class Complexity"
filename <- "prod_class_complexity"
drawBoxplot(data, data$mde, data$prod_class_complexity, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_class_complexity, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

data <- product
data <- data[! is.na(data$prod_functions_complexity),]
title <- "Function Complexity"
filename <- "prod_functions_complexity"
drawBoxplot(data, data$mde, data$prod_functions_complexity, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_functions_complexity, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

data <- product
data <- data[! is.na(data$prod_file_complexity),]
title <- "File Complexity"
filename <- "prod_file_complexity"
drawBoxplot(data, data$mde, data$prod_file_complexity, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_file_complexity, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

# Changeability
data <- product
data <- data[! is.na(data$prod_code_smells),]
title <- "Code Smells"
filename <- "prod_code_smells"
drawBoxplot(data, data$mde, data$prod_code_smells, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_code_smells, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

# Reliability
data <- product
data <- data[! is.na(data$prod_open_issues),]
title <- "Number of open issues"
filename <- "prod_open_issues"
drawBoxplot(data, data$mde, data$prod_open_issues, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_open_issues, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

# Reusability
data <- product
data <- data[! is.na(data$prod_comment_density),]
title <- "Comment Lines Density"
filename <- "prod_comment_density"
drawBoxplot(data, data$mde, data$prod_comment_density, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_comment_density, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

data <- product
data <- data[!is.na(data$prod_technical_debt),]
title <- "Technical Debt"
filename <- "prod_technical_debt"
drawBoxplot(data, data$mde, data$prod_technical_debt, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$prod_technical_debt, data$incubation, title, paste(filename, "-inc" , extension, sep=""), outputPath)

