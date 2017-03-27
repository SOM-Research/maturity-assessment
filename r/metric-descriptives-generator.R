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
                 metrics_descriptives_project mep, project_type pt
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

# Main distribution
ecosystem$type <- factor(c("MDE-Incubation", "MDE-NoIncubation", "NoMDE-Incubation", "NoMDE-NoIncubation"))
ecosystem$type[ecosystem$mde=='Y' & ecosystem$incubation=='Y']<-"MDE-Incubation"
ecosystem$type[ecosystem$mde=='Y' & ecosystem$incubation=='N']<-"NoMDE-Incubation"
ecosystem$type[ecosystem$mde=='N' & ecosystem$incubation=='Y']<-"NoMDE-Incubation"
ecosystem$type[ecosystem$mde=='N' & ecosystem$incubation=='N']<-"NoMDE-NoIncubation"
ecosystem$type <- reorder(ecosystem$type, X = ecosystem$type, FUN = function(x) -length(x))
at <- nrow(ecosystem) - as.numeric(cumsum(sort(table(ecosystem$type)))-0.5*sort(table(ecosystem$type)))
label=paste0(sort(table(ecosystem$type)), " (" , round(sort(table(ecosystem$type))/sum(table(ecosystem$type)),4) * 100,"%)")
ggplot(ecosystem, aes(x="", fill = ecosystem$type)) +
  geom_bar(width = 1) +
  coord_polar(theta="y") +
  scale_fill_manual(
    values = c('MDE-Incubation' = "#a04343", 'MDE-NoIncubation' = "#51a043", 
               'NoMDE-Incubation' = "#e85f5f", 'NoMDE-NoIncubation' = "#6edd5a")
  ) +
  annotate(geom = "text", y = at, x = 1, label = label)  +
  labs(title="Main project distribution", x="",  y="", fill="Project type") +
  theme(legend.position="right", axis.title.x = element_blank(),
        text = element_text(size=14.5, colour="black")) 
setwd(outputPath)
ggsave(filename="main_distribution.png", width=10, height = 6)

data <- ecosystem
data <- data[! is.na(data$num_commits),]
title <- "Total number of commits"
filename <- "num_commits"
drawBoxplot(data, data$mde, data$num_commits, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$num_commits, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$num_authors),]
title <- "Total number of authors"
filename <- "num_authors"
drawBoxplot(data, data$mde, data$num_authors, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$num_authors, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$num_committers),]
title <- "Total number of committers"
filename <- "num_committers"
drawBoxplot(data, data$mde, data$num_committers, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$num_committers, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$commit_size),]
title <- "AVG Commit Size"
filename <- "commit_size"
drawBoxplot(data, data$mde, data$commit_size, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$commit_size, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$num_files),]
title <- "Total number of files"
filename <- "num_files"
drawBoxplot(data, data$mde, data$num_files, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$num_files, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
outlierKDNoPrompt(data, commits_vs_num_files)
data <- data[! is.na(data$commits_vs_num_files),]
title <- "Number of commits vs. Number of files (No outliers)"
filename <- "commits_vs_num_files"
drawBoxplot(data, data$mde, data$commits_vs_num_files, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$commits_vs_num_files, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

