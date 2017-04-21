###########################################################################################################
## Init things for accessing the database.
##  
## Dependencies:
## - You must import the set of tables including the metrics results
## 
## License: 
##   Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
##   (https://creativecommons.org/licenses/by-sa/4.0/)
###########################################################################################################

library(RMySQL)

con <- dbConnect(MySQL(), 
                 user="YOUR_USER", 
                 password="YOUR_PASSWORD", 
                 dbname="eclipse_projects_master_23032017", 
                 host="YOUR_DB_HOST")

# Descriptives data
getDescriptives <- function(dt, var) {
  sol <- getData("SELECT pt.*, mep.* FROM metrics_descriptives_project mep, project_type pt
                  WHERE mep.project_id = pt.project_id")
  return(sol)
}

# Ecosystem data
getEcosystem <- function(dt, var) {
  sol <- getData("SELECT pt.*, mep.* FROM metrics_ecosystem_project mep, project_type pt
                  WHERE mep.project_id = pt.project_id")
  return(sol)
}

# Process data
getProcess <- function(dt, var) {
  sol <- getData("SELECT pt.*, mep.* FROM metrics_process_project mep, project_type pt
                  WHERE mep.project_id = pt.project_id")
  return(sol)
}

# Product data
getProduct <- function(dt, var) {
  sol <- getData("SELECT pt.*, mep.* FROM metrics_product_project mep, project_type pt
                  WHERE mep.project_id = pt.project_id")
  return(sol)
}

# Get data forum for Papyrus
getForumPapyrus <- function(dt, var) {
  rs = dbSendQuery(con, "SELECT * FROM papyrus_gitana.metrics_forum")
  dt = fetch(rs, n=-1)
  return(dt)
}

# Get data forum for JDT
getForumJDT <- function(dt, var) {
  rs = dbSendQuery(con, "SELECT * FROM jdt_gitana.metrics_forum")
  dt = fetch(rs, n=-1)
  return(dt)
}

# Bus factor
getBusFactor <- function(dt, var) {
  rs = dbSendQuery(con, "SELECT pt.*, mbf.* FROM metrics_bus_factor mbf, project_type pt
                 WHERE mbf.project_id = pt.project_id")
  dt = fetch(rs, n=-1)
  dt$mde[dt$mde==1]<-"Y"
  dt$mde[dt$mde==0]<-"N"
  dt$mde = as.factor(dt$mde)
  dt$incubation[dt$incubation==1]<-"Y"
  dt$incubation[dt$incubation==0]<-"N"
  dt$incubation = as.factor(dt$incubation)
  dt$automatic[dt$automatic==1]<-"Y"
  dt$automatic[dt$automatic==0]<-"N"
  dt$automatic = as.factor(dt$automatic)
  #dt$bus_factor = as.factor(dt$bus_factor)
  dt$type[dt$mde=='Y' & dt$incubation=='Y']<-"MDE-Incubation"
  dt$type[dt$mde=='Y' & dt$incubation=='N']<-"MDE-NoIncubation"
  dt$type[dt$mde=='N' & dt$incubation=='Y']<-"NoMDE-Incubation"
  dt$type[dt$mde=='N' & dt$incubation=='N']<-"NoMDE-NoIncubation"
  dt$type <- as.factor(dt$type)
  return(dt)
}

# Generic function to retrieve data
getData <- function(query) {
  rs = dbSendQuery(con, query)
  dataRetrieved = fetch(rs, n=-1)
  dataRetrieved <- shapeData(dataRetrieved)
  return(dataRetrieved)
}

# Shapes the dataframe with the factors we need
shapeData <- function(dt) {
  dt$mde[dt$mde==1]<-"Y"
  dt$mde[dt$mde==0]<-"N"
  dt$mde = as.factor(dt$mde)
  dt$incubation[dt$incubation==1]<-"Y"
  dt$incubation[dt$incubation==0]<-"N"
  dt$incubation = as.factor(dt$incubation)
  dt$automatic[dt$automatic==1]<-"Y"
  dt$automatic[dt$automatic==0]<-"N"
  dt$automatic = as.factor(dt$automatic)
  dt$type[dt$mde=='Y' & dt$incubation=='Y']<-"MDE-Incubation"
  dt$type[dt$mde=='Y' & dt$incubation=='N']<-"MDE-NoIncubation"
  dt$type[dt$mde=='N' & dt$incubation=='Y']<-"NoMDE-Incubation"
  dt$type[dt$mde=='N' & dt$incubation=='N']<-"NoMDE-NoIncubation"
  dt$type <- as.factor(dt$type)
  return(dt)
}

