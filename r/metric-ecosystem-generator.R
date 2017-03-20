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
                 metrics_ecosystem_project mep, project_type pt
                 WHERE
                 mep.project_id = pt.project_id")
ecosystem = fetch(rs, n=-1)
ecosystem$mde[ecosystem$mde==1]<-"Y"
ecosystem$mde[ecosystem$mde==0]<-"N"
ecosystem$mde = as.factor(ecosystem$mde)
ecosystem$incubation[ecosystem$incubation==1]<-"Y"
ecosystem$incubation[ecosystem$incubation==0]<-"N"
ecosystem$incubation = as.factor(ecosystem$incubation)
ecosystem$incubation <- factor(ecosystem$incubation, levels = rev(levels(ecosystem$incubation)))
ecosystem$automatic[ecosystem$automatic==1]<-"Y"
ecosystem$automatic[ecosystem$automatic==0]<-"N"
ecosystem$automatic = as.factor(ecosystem$automatic)

###################
## BOXPLOTS
###################

# Activity
data <- ecosystem
data <- data[! is.na(data$act_avg_commits_developer),]
title <- "AVG Number of commits per developer"
filename <- "act_avg_commits_developer"
drawBoxplot(data, data$mde, data$act_avg_commits_developer, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$act_avg_commits_developer, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$act_avg_num_commits_month),]
title <- "AVG number of commits per month in the project"
filename <- "act_avg_num_commits_month"
drawBoxplot(data, data$mde, data$act_avg_commits_developer, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$act_avg_commits_developer, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
outlierKDNoPrompt(data, act_avg_size_commit_developer)
data <- data[! is.na(data$act_avg_size_commit_developer),]
title <- "AVG commit size per developer (No outliers)"
filename <- "act_avg_size_commit_developer"
drawBoxplot(data, data$mde, data$act_avg_size_commit_developer, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$act_avg_size_commit_developer, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
outlierKDNoPrompt(data, act_num_developers)
data <- data[! is.na(data$act_num_developers),]
title <- "Number of unique developers (No outliers)"
filename <- "act_num_developers"
drawBoxplot(data, data$mde, data$act_num_developers, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$act_num_developers, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

# diversity
data <- ecosystem
data <- data[! is.na(data$div_ratio_outsiders),]
title <- "Ratio of outsiders"
filename <- "div_ratio_outsiders"
drawBoxplot(data, data$mde, data$div_ratio_outsiders, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$div_ratio_outsiders, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$div_ratio_eclipse_email),]
title <- "Ratio of users with eclipse email"
filename <- "div_ratio_eclipse_email"
drawBoxplot(data, data$mde, data$div_ratio_eclipse_email, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$div_ratio_eclipse_email, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$div_ratio_commits_from_top_3_committers),]
title <- "Ratio commits from Top 3 committers"
filename <- "div_ratio_commits_from_top_3_committers"
drawBoxplot(data, data$mde, data$div_ratio_commits_from_top_3_committers, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$div_ratio_commits_from_top_3_committers, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

data <- ecosystem
data <- data[! is.na(data$div_ratio_casuals),]
title <- "Ratio casual devs (devs with less than 5% of project commits)"
filename <- "div_ratio_casuals"
drawBoxplot(data, data$mde, data$div_ratio_casuals, title, paste(filename, ".png", sep=""), outputPath)
drawBoxplotDouble(data, data$mde, data$div_ratio_casuals, data$incubation, title, paste(filename, "-inc.png", sep=""), outputPath)

# support
data <- ecosystem
outlierKDNoPrompt(data, sup_md_files)
data <- data[! is.na(data$sup_md_files),]
smf <- ggplot(data, aes(x=data$mde, y=data$sup_md_files)) + 
  geom_point(size=4) +
  labs(title=paste("AVG number of .md files (no outliers)", "(n = ", nrow(data), ")"), x="Modeling project",  y="") +
  theme(legend.position="none", axis.title.x = element_blank(),
        text = element_text(size=14.5, colour="black")) +
  coord_flip()
smf
setwd(outputPath)
ggsave(filename="sup_md_files.png", width=10, height = 3)
smfInc <- ggplot(data, aes(x=data$mde, y=data$sup_md_files)) + 
  geom_point(aes(colour=data$incubation), size=4) +
  labs(title=paste("AVG number of .md files (no outliers)", "(n = ", nrow(data), ")"), x="Modeling project",  y="") +
  theme(legend.position="bottom", axis.title.x = element_blank(),
        text = element_text(size=14.5, colour="black")) +
  scale_color_manual(name="Incubation project", values = c('Y' = "#a04343", 'N' = "#51a043")) +
  coord_flip()
smfInc
setwd(outputPath)
ggsave(filename="sup_md_files-inc.png", width=10, height = 3)

#############################
## More precise analysis
#############################

# Life of the project the first 12 months
rs = dbSendQuery(con, "SELECT * from metrics_ecosystem_act_starting")
activity = fetch(rs, n=-1)
activity$mde[activity$mde==1]<-"Y"
activity$mde[activity$mde==0]<-"N"
activity$mde = as.factor(activity$mde)
activity$incubation[activity$incubation==1]<-"Y"
activity$incubation[activity$incubation==0]<-"N"
activity$incubation = as.factor(activity$incubation)
activity$repo_id = as.factor(activity$repo_id)
ggplot(activity, aes(x=activity$row_number, y=activity$num_commits, group=activity$repo_id, colour=activity$mde)) +
  scale_x_continuous(breaks=1:12) +
  labs(title=paste("Activity first 12 months"), x="Project",  y="Number of commits",
       color = "Modeling project") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  geom_line()
setwd(outputPath)
ggsave(filename="act_first_12_months.png", width=8, height = 4)

ggplot(activity, aes(x=activity$row_number, y=activity$num_commits, group=activity$repo_id, colour=activity$incubation)) +
  scale_x_continuous(breaks=1:12) +
  labs(title=paste("Activity first 12 months"), x="Project",  y="Number of commits",
       color = "Incubation project") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  geom_line()
setwd(outputPath)
ggsave(filename="act_first_12_months-inc.png", width=8, height = 4)

# Life of the project the first 12 months CONSECUTIVES
rs = dbSendQuery(con, "SELECT * from metrics_ecosystem_act_consecutive")
activity = fetch(rs, n=-1)
activity$mde[activity$mde==1]<-"Y"
activity$mde[activity$mde==0]<-"N"
activity$mde = as.factor(activity$mde)
activity$incubation[activity$incubation==1]<-"Y"
activity$incubation[activity$incubation==0]<-"N"
activity$incubation = as.factor(activity$incubation)
activity$repo_id = as.factor(activity$repo_id)
ggplot(activity, aes(x=activity$month, y=activity$num_commits, group=activity$repo_id, colour=activity$mde)) +
  scale_x_continuous(breaks=1:12) +
  labs(title=paste("Activity first 12 months consecutives"), x="Project",  y="Number of commits",
       color = "Modeling project") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  geom_line()
setwd(outputPath)
ggsave(filename="act_first_12_months_consecutive.png", width=8, height = 4)

ggplot(activity, aes(x=activity$month, y=activity$num_commits, group=activity$repo_id, colour=activity$incubation)) +
  scale_x_continuous(breaks=1:12) +
  labs(title=paste("Activity first 12 months consecutives"), x="Project",  y="Number of commits",
       color = "Incubation project") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  geom_line()
setwd(outputPath)
ggsave(filename="act_first_12_months_consecutive-inc.png", width=8, height = 4)

# Life of the project monthly 
rs = dbSendQuery(con, "SELECT * from metrics_ecosystem_act_monthly")
activity = fetch(rs, n=-1)
activity$mde[activity$mde==1]<-"Y"
activity$mde[activity$mde==0]<-"N"
activity$mde = as.factor(activity$mde)
activity$incubation[activity$incubation==1]<-"Y"
activity$incubation[activity$incubation==0]<-"N"
activity$incubation = as.factor(activity$incubation)
activity$repo_id = as.factor(activity$repo_id)
ggplot(activity, aes(x=activity$month, y=activity$num_commits, group=activity$repo_id, colour=activity$mde)) +
  scale_x_continuous(breaks=1:12) +
  labs(title=paste("Monthly activity"), x="Project",  y="Number of commits",
       color = "Modeling project") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  geom_line()
setwd(outputPath)
ggsave(filename="act_monthly_activity.png", width=8, height = 4)

ggplot(activity, aes(x=activity$month, y=activity$num_commits, group=activity$repo_id, colour=activity$incubation)) +
  scale_x_continuous(breaks=1:12) +
  labs(title=paste("Monthly activity"), x="Project",  y="Number of commits",
       color = "Incubation project") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  geom_line()
setwd(outputPath)
ggsave(filename="act_monthly_activity-inc.png", width=8, height = 4)

