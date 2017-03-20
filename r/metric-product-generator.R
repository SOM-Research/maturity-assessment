###########################################################################################################
## Main functions used to study metrics 
##  
## Dependencies:
##  - database.R
##  - utils.R
##
## License: 
##   Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
##   (https://creativecommons.org/licenses/by-sa/4.0/)
###########################################################################################################

# setting random seed
set.seed(123)

# cleaning memory
rm(list=ls())

# setting input/output folders
inputPath <- "FOLDER_TO_READ_FILES_FROM"
utilsPath <- "FOLDER_WITH_UTILS"
outputPath<- "FOLDER_WHERE_GRAPHS_WILL_BE_GENERATED"

# Importing utils
setwd(utilsPath)
source("database.R")
setwd(utilsPath)
source("utils.R")

# PROJECTS
rs = dbSendQuery(con, "SELECT pt.*, mep.* FROM
                 metrics_product_project mep, project_type pt
                 WHERE
                 mep.project_id = pt.project_id")
ecosystem = fetch(rs, n=-1)
ecosystem$mde[ecosystem$mde==1]<-"Y"
ecosystem$mde[ecosystem$mde==0]<-"N"
ecosystem$mde = as.factor(ecosystem$mde)
ecosystem$incubation[ecosystem$incubation==1]<-"Y"
ecosystem$incubation[ecosystem$incubation==0]<-"N"
ecosystem$incubation = as.factor(ecosystem$incubation)
ecosystem$automatic[ecosystem$automatic==1]<-"Y"
ecosystem$automatic[ecosystem$automatic==0]<-"N"
ecosystem$automatic = as.factor(ecosystem$automatic)

###################
## BOXPLOTS
###################


# Analyzability
data <- ecosystem
data <- data[! is.na(data$anal_size),]
title <- "Lines of code"
filename <- "anal_size"
drawBoxplot(data, data$mde, data$anal_size, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$anal_size, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$anal_num_extensions),]
title <- "Number of file types (extensions)"
filename <- "anal_num_extensions"
drawBoxplot(data, data$mde, data$anal_num_extensions, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$anal_num_extensions, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$anal_class_complexity),]
title <- "Class Complexity"
filename <- "anal_class_complexity"
drawBoxplot(data, data$mde, data$anal_class_complexity, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$anal_class_complexity, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$anal_functions_complexity),]
title <- "Function Complexity"
filename <- "anal_functions_complexity"
drawBoxplot(data, data$mde, data$anal_functions_complexity, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$anal_functions_complexity, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$anal_file_complexity),]
title <- "File Complexity"
filename <- "anal_file_complexity"
drawBoxplot(data, data$mde, data$anal_file_complexity, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$anal_file_complexity, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

# Changeability
data <- ecosystem
data <- data[! is.na(data$change_code_smells),]
title <- "Code Smells"
filename <- "change_code_smells"
drawBoxplot(data, data$mde, data$change_code_smells, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$change_code_smells, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

# Reliability
data <- ecosystem
data <- data[! is.na(data$rel_open_issues),]
title <- "Number of open issues"
filename <- "rel_open_issues"
drawBoxplot(data, data$mde, data$rel_open_issues, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$rel_open_issues, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

# Reusability
data <- ecosystem
data <- data[! is.na(data$reus_comment_lines_density),]
title <- "Comment Lines Density"
filename <- "reus_comment_lines_density"
drawBoxplot(data, data$mde, data$reus_comment_lines_density, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$reus_comment_lines_density, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$reus_technical_debt),]
title <- "Technical Debt"
filename <- "reus_technical_debt"
drawBoxplot(data, data$mde, data$reus_technical_debt, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$reus_technical_debt, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)
