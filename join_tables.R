
# Load packages ################################################################
library(dplyr)



# Read in all tables ################################################################

citiTrips <- read.csv(file=file.choose()) # all_2014_trips.csv
citiDistance <- read.csv(file=file.choose()) # citi_to_nearest_subway_distance.csv
subwayStatus <- read.csv(file=file.choose()) # mta_station_status_hourly.csv
weatherData <- read.csv(file=file.choose()) # weather_data.csv



# Join the data files ################################################################

allData <- left_join(x=citiTrips, y=citiDistance, by="citiStationID")

allData <- left_join(x=allData, y=subwayStatus, by=c("date", "hour", "subStationID"))

allData <- left_join(x=allData, y=weatherData, by=c("date"))



# Create some indicator variables ################################################################

# Weekday (1) vs weekend (0)
allData$day <- as.factor(weekdays(as.Date(allData$date)))
allData$weekday <- NA
allData$weekday <- sub("Saturday|Sunday", 0, allData$day)
allData$weekday <- sub("Monday|Tuesday|Wednesday|Thursday|Friday", 1, allData$weekday)
allData$weekday <- as.factor(allData$weekday)
allData$day <- NULL

# Any precipitation (1), vs no precipitation (0)
allData$anyPrecip <- 0
allData$anyPrecip[which(allData$precip>0)] <- 1



# Rename/remove/reorder columns ################################################################

allData <- select(allData,
                  date, hour, weekday,
                  citiStationID, trips, 
                  nearestSubStationDist=distance, avgSubStationStatus=avgStatus,
                  precip=precipitation, anyPrecip, maxTemp=maxTemperature)



# Write allData to csv ################################################################

write.csv(allData, file="~/Desktop/all_data.csv", row.names=F)


