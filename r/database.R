###########################################################################################################
## Init things for accessing the database
##  
## License: 
##   Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
##   (https://creativecommons.org/licenses/by-sa/4.0/)
###########################################################################################################

library(RMySQL)

con <- dbConnect(MySQL(), 
                 user="YOUR_USER", 
                 password="YOUR_PASSWORD", 
                 dbname="eclipse_projects_14022017", 
                 host="som.uoc.es")


