###########################################################################################################
## Main utility classes
##
## Dependencies:
##  - None
##
## License: 
##   Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
##   (https://creativecommons.org/licenses/by-sa/4.0/)
###########################################################################################################

library(reshape2)
library(ggplot2)
library(lmtest)
library(car)
library(plyr)
require(foreign)
require(MASS)
library(multcomp)
library(nparcomp)
library(moments)

# Draws a boxplot with a title for yData given xData factor.
# Saves the resulting boxplot in outputPath/fileName
drawBoxplot <- function(data, xData, yData, title, fileName, outputPath) {
  plt <- ggplot(data, aes(x=xData, y=yData)) + 
    geom_boxplot(width=0.4) +
    #labs(title=paste(title, "(n = ", nrow(data), ")"), x="Modeling project",  y="") +
    labs(title=paste(title), x="Modeling project",  y="") +
    theme(legend.position="none", axis.title.x = element_blank(),
          text = element_text(size=14.5, colour="black")) +
    coord_flip()
  setwd(outputPath)
  ggsave(filename=fileName, width=10, height = 2)
  return(plt)
}

# Draws a boxplot with a title for yData given xData and fillData factors (double factors)
# Saves the resulting boxplot in outputPath/fileName
drawBoxplotDouble <- function(data, xData, yData, fillData, title, fileName, outputPath) {
  plt <- ggplot(data, aes(x=xData, y=yData, fill=fillData)) + 
    geom_boxplot(width=0.65) +
    #labs(title=paste(title, "(n = ", nrow(data), ")"), x="Modeling project",  y="") +
    labs(title=paste(title), x="Modeling project",  y="") +
    theme(legend.position="bottom", axis.title.x = element_blank(),
          text = element_text(size=14.5, colour="black")) +
    guides(fill=guide_legend(reverse=TRUE), colour=guide_legend(reverse=TRUE)) +
    scale_fill_manual(name="Incubation project", values = c('Y' = "#666666", 'N' = "#ffffff")) +
    coord_flip()
  setwd(outputPath)
  ggsave(filename=fileName, width=10, height = 2.5)
  return(plt)
}

