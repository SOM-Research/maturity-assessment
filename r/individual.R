###########################################################################################################
## Procedure followed to study distributions individually
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

# Main data (to be used individually later)
product <- getProduct()
ecosystem <- getEcosystem()

########################
# Analysis (RQ1)
########################

# Step 1. Initialize "myData" with your main data frame
#         Afterwards, find&replace the access to the proper column 
#         (illustrated here with "eco_num_commits")
myData <- ecosystem

# Step 2. (Optional) Removing NA's 
myData <- myData[!is.na(myData$eco_num_commits),]

# Step 3. Variable study
# Skewness study
skewness(myData$eco_num_commits)
# Kurtosis
kurtosis(myData$eco_num_commits)

# Step 4. (Optional) Variable transformation (select one)
myData$eco_num_commits <- myData$eco_num_commits^2
myData$eco_num_commits <- myData$eco_num_commits^2.5
myData$eco_num_commits <- myData$eco_num_commits^3
myData$eco_num_commits <- myData$eco_num_commits^4 
myData$eco_num_commits <- myData$eco_num_commits^(1/3)
myData$eco_num_commits <- log(myData$eco_num_commits)
myData$eco_num_commits <- sqrt(myData$eco_num_commits)
myData$eco_num_commits <- 1/(myData$eco_num_commits)
myData$eco_num_commits <- 1/((myData$eco_num_commits)^2)
myData$eco_num_commits <- (myData$eco_num_commits)^(-2)

# Step 4. (Optional) Remove Outliers
box <- boxplot(myData$eco_num_commits)
outliers <- box$out
length(outliers)
myData <- myData[!myData$eco_num_commits%in%outliers,]
boxplot(myData$eco_num_commits)

# Step 5. Normality test (assumption 1)
shapiro.test(myData$eco_num_commits)

# Step 6. Equality of Variances (assumption 2)
bartlett.test(myData$eco_num_commits~myData$mde, data=myData)

# Step 7a. (If assumptions are met) Student's t-test
t.test(myData$eco_num_commits~myData$mde)

# Step 7b. (If normal but non-equality of variances) Nonparametric Behrens-Fisher problem
b <- npar.t.test(myData$eco_num_commits~myData$mde, data = myData, method="permu", alternative="two.sided", info=FALSE, plot.simci=TRUE)
b$Analysis$p.value
summary(b)

# Step 7c. (When not normal by equality of variances) Wilcoxon test
wilcox.test(myData$eco_num_commits~myData$mde)


########################
# Analysis (RQ2)
########################

# Step 1a. ANOVA
an <- aov(myData$eco_num_commits~type, myData)
summary(an)
summary(glht(an, linfct = mcp(type="Tukey")))

# Step 1b. T tilde
t <- mctp(myData$eco_num_commits~type, data = myData, asy.method="fisher", type="Tukey", alternative="two.sided", info=FALSE, plot.simci=FALSE)
summary(t)







