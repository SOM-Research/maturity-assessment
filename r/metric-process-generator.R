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
                 metrics_process_project mep, project_type pt
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


# Configuration Management
data <- ecosystem
data <- data[! is.na(data$conf_manag_commits),]
title <- "Total number of commits"
filename <- "conf_manag_commits"
drawBoxplot(data, data$mde, data$conf_manag_commits, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$conf_manag_commits, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$conf_manag_committers),]
title <- "Total number of committers"
filename <- "conf_manag_committers"
drawBoxplot(data, data$mde, data$conf_manag_committers, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$conf_manag_committers, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

# Change Management
data <- ecosystem
data <- data[! is.na(data$change_manag_governance),]
title <- "Existence of governance.md or contribution.md"
filename <- "change_manag_governance"
drawBoxplot(data, data$mde, data$change_manag_governance, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$change_manag_governance, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

# Intellectual property Management
data <- ecosystem
data <- data[! is.na(data$int_license),]
il <- ggplot(data, aes(x=data$mde, y=data$int_license)) + 
  geom_point(size=4) +
  labs(title=paste("Existence of license.md", "(n = ", nrow(data), ")"), x="Modeling project",  y="") +
  theme(legend.position="none", axis.title.x = element_blank(),
        text = element_text(size=14.5, colour="black")) +
  coord_flip()
il
setwd(outputPath)
ggsave(filename="int_license.png", width=10, height = 3)
ilInc <- ggplot(data, aes(x=data$mde, y=data$int_license)) + 
  geom_point(aes(colour=data$incubation),size=4) +
  labs(title=paste("Existence of license.md", "(n = ", nrow(data), ")"), x="Modeling project",  y="") +
  theme(legend.position="bottom", axis.title.x = element_blank(),
        text = element_text(size=14.5, colour="black")) +
  scale_color_manual(name="Incubation project", values = c('Y' = "#a04343", 'N' = "#51a043")) +
  coord_flip()
ilInc
setwd(outputPath)
ggsave(filename="int_license-inc.png", width=10, height = 3)
