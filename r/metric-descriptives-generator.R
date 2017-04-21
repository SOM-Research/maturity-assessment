###########################################################################################################
## Main functions used to study the main descriptive statistics of the dataset.
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
descriptives <- getDescriptives()

#############################
## BOXPLOTS FOR THE PAPER
#############################

# Main distribution
descriptives$type <- reorder(descriptives$type, X = descriptives$type, FUN = function(x) -length(x))
at <- nrow(descriptives) - as.numeric(cumsum(sort(table(descriptives$type)))-0.5*sort(table(descriptives$type)))
label=paste0(sort(table(descriptives$type)), " (" , round(sort(table(descriptives$type))/sum(table(descriptives$type)),4) * 100,"%)")
ggplot(descriptives, aes(x="", fill = descriptives$type)) +
  geom_bar(width = 1) +
  coord_polar(theta="y") +
  scale_fill_manual(
    values = c('MDE-Incubation' = "#9b9b9b", 'MDE-NoIncubation' = "#c6c6c6", 
               'NoMDE-Incubation' = "#828080", 'NoMDE-NoIncubation' = "#f7f7f7")
  ) +
  annotate(geom = "text", y = at, x = 1, label = label)  +
  labs(title="Main project distribution", x="",  y="", fill="Project type") +
  theme(legend.position="bottom", axis.title.x = element_blank(),
        text = element_text(size=14.5, colour="black")) 
setwd(outputPath)
filename <- paste("main_distribution", extension, sep="")
ggsave(filename=filename, width=10, height = 6)

data <- descriptives
data <- data[! is.na(data$num_commits),]
title <- "Total number of commits"
filename <- "num_commits"
drawBoxplot(data, data$mde, data$num_commits, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$num_commits, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- descriptives
data <- data[! is.na(data$num_contributors),]
title <- "Total number of contributors"
filename <- "num_contributors"
drawBoxplot(data, data$mde, data$num_contributors, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$num_contributors, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)

data <- descriptives
data <- data[! is.na(data$num_files),]
title <- "Total number of files"
filename <- "num_files"
drawBoxplot(data, data$mde, data$num_files, title, paste(filename, extension, sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$num_files, data$incubation, title, paste(filename, "-inc", extension, sep=""), outputPath)
