###########################################################################################################
## Main functions used to generate the content related to extensions to our maturity model
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

###################
## BUSFACTOR
###################

bus <- getBusFactor()

bus <- ddply(bus, "project_id", transform, bus_factor_percent = bus_factor / sum(bus_factor) * 100)

# stacked bar
Y <- data.frame(mde=factor(c("Y")), 
                bus_factor=table(bus[bus$mde=="Y",]$bus_factor)/sum(table(bus[bus$mde=="Y",]$bus_factor)),
                label=paste0(round(table(bus[bus$mde=="Y",]$bus_factor)/sum(table(bus[bus$mde=="Y",]$bus_factor)),4) * 100,"%")
                )
Y <- ddply(Y, "mde", transform, label_y=cumsum(Y$bus_factor.Freq)-(Y$bus_factor.Freq/2))
N <- data.frame(mde=factor(c("N")),
                bus_factor=table(bus[bus$mde=="N",]$bus_factor)/sum(table(bus[bus$mde=="N",]$bus_factor)),
                label=paste0(round(table(bus[bus$mde=="N",]$bus_factor)/sum(table(bus[bus$mde=="N",]$bus_factor)),4) * 100,"%")
                )
N <- ddply(N, "mde", transform, label_y=cumsum(N$bus_factor.Freq)-(N$bus_factor.Freq/2))
toPlot <- merge(N, Y, all=TRUE)

ggplot(toPlot, aes(x=toPlot$mde,y=toPlot$bus_factor.Freq,fill=factor(toPlot$bus_factor.Var1) )) +
  geom_bar(stat="identity") +
  annotate(geom = "text", y = toPlot$label_y, x=toPlot$mde, label = toPlot$label)  +
  labs(title=paste("Bus Factor"), y="Ratio of projects",  x="Modeling Project",
       fill = "Bus Factor Assessment") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  scale_fill_manual(values=c("#828080", "#9b9b9b", "#c6c6c6")) + 
  coord_flip()
setwd(outputPath)
ggsave(filename=paste("bus_factor", extension, sep=""), width=10, height = 3.5)

# boxplot

ggplot(data, aes(x=xData, y=yData, fill=fillData)) + 
  geom_boxplot(width=0.65) +
  #labs(title=paste(title, "(n = ", nrow(data), ")"), x="Modeling project",  y="") +
  labs(title=paste(title), x="Modeling project",  y="") +
  theme(legend.position="bottom", axis.title.x = element_blank(),
        text = element_text(size=14.5, colour="black")) +
  guides(fill=guide_legend(reverse=TRUE), colour=guide_legend(reverse=TRUE)) +
  scale_fill_manual(name="Incubation project", values = c('Y' = "#666666", 'N' = "#ffffff")) +
  coord_flip()  

###################
## FORUM ACTIVITY
###################

# Preparing the data
forumA <- getForumJDT()
forumA <- forumA[!forumA$ratio_messages_per_topic == 1,] # remove the peaks
forumA$project <- factor(c("JDT"))

forumB <- getForumPapyrus()
forumB <- forumB[!forumB$ratio_messages_per_topic == 1,] # remove the peak
forumB$project <- factor(c("Papyrus"))

forum <- merge(forumA, forumB, all=TRUE)
forum$timestamp <- ISOdatetime(year=forum$year, month=forum$month, day=1, hour=0, min=0, sec=0)

# First analysis: ratio of messages per topic (per month)
ggplot(forum, aes(x=forum$timestamp, y=forum$ratio_messages_per_topic, colour=forum$project)) +
  geom_line() +
  labs(title=paste("Ratio of messages per topic"), y="",  x="",
       colour = "Project") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  scale_colour_grey()
setwd(outputPath)
ggsave(filename=paste("forum-ratio-messages", extension, sep=""), width=10, height = 3)

# Second analysis: ratio of contributors per topic (per month)
ggplot(forum, aes(x=forum$timestamp, y=forum$ratio_contributors_per_topic, colour=forum$project)) +
  geom_line() +
  labs(title=paste("Ratio of contributors per topic"), y="",  x="",
       colour = "Project") +
  theme(legend.position="bottom", text = element_text(size=14.5, colour="black")) +
  scale_colour_grey()
setwd(outputPath)
ggsave(filename=paste("forum-ratio-contributors", extension, sep=""), width=10, height = 3)

