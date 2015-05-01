
# Load packages ################################################################
library(dplyr)
library(data.table)
library(reshape2)



# Read in location and line data ################################################################

subwayLoc <- read.csv(file=file.choose(), header=T, col.names=c("subStationID", "subStationName", "latitude", "longitude"))

citiLoc <- read.csv(file=file.choose())
setnames(citiLoc, "station_id", "citiStationID")

subwayLines <- read.csv(file=file.choose(), header=T, col.names=c("subStationID", "line"))





# Define a distance function ################################################################

# Manhattan distance (with rotation)
ManDist <- function(latitude1, longitude1, latitude2, longitude2) {
  
  theta <- -0.51 # NYC rotation (radians)
  
  newLong1 <- ((longitude1 * cos(theta)) + (latitude1 * sin(theta)))
  newLat1 <- ((latitude1 * cos(theta)) - (longitude1 * sin(theta)))
  
  newLong2 <- ((longitude2 * cos(theta)) + (latitude2 * sin(theta)))
  newLat2 <- ((latitude2 * cos(theta)) - (longitude2 * sin(theta)))
  
  abs(newLong1 - newLong2) + abs(newLat1 - newLat2)
  
}



# Find nearest station ################################################################

nearest <- data.frame()
for (i in 1:nrow(citiLoc)) {
  
  distance <- ManDist(citiLoc$latitude[i], citiLoc$longitude[i], subwayLoc$latitude, subwayLoc$longitude)  
  
  temp.nearest <- cbind(subwayLoc, distance) %>%
    select(subStationID, subStationName, distance) %>%
    filter(distance==min(distance))
  
  temp.nearest <- cbind(citiStationID=citiLoc$citiStationID[i], temp.nearest)[1,]
  
  nearest <- rbind(nearest, temp.nearest)
  
  rm(distance, temp.nearest)
}

rm(i)


# Join with subway line data ################################################################

# test <- left_join(x=nearest, y=subwayLines, by="subStationID")
# test <- dcast(data=nearest, formula=citiStationID+subStationID+subStationName+distance~line, value.var=1)




# Write to csv ################################################################

write.csv(nearest, file="~/Desktop/citi_to_nearest_subway_distance.csv", row.names=F)


