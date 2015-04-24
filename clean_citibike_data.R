
# Load packages ################################################################
library(dplyr)
library(data.table)
library(stringr)



# Read raw Citibike trip data ################################################################

# Read in the all_2014_trips.csv file
raw.tripData <- read.csv(file=file.choose(), header=F, col.names=c("trips", "dateHour", "citiStationID"))
tripData <- raw.tripData



# Clean trip data ################################################################

# Parse date and hour from dateHour field
tripData$date <- sub("^(.*?) .*", "\\1", tripData$dateHour)
tripData$hour <- str_sub(tripData$dateHour, start=-2)

# Keep only the clean fields
tripData <- select(tripData, date, hour, citiStationID, trips)

# Index the records with date format "%m/%d/%Y"
temp.badDates.ndx <- grep("/",tripData$date)

# Create temporary tables for the different date formats
temp.badDates <- tripData[temp.badDates.ndx,]
temp.goodDates <- tripData[-temp.badDates.ndx,]

# Convert date fields to dates
temp.badDates$date <- as.Date(temp.badDates$date, format="%m/%d/%Y")
temp.goodDates$date <- as.Date(temp.goodDates$date, format="%Y-%m-%d")

# Combine the temporary tables
tripData <- rbindlist(list(temp.goodDates, temp.badDates)) %>% arrange(date)

# Remove the temporary tables
rm(temp.badDates.ndx, temp.badDates, temp.goodDates)

# Assign data types
tripData$hour <- as.integer(tripData$hour)
tripData$citiStationID <- as.factor(tripData$citiStationID)
tripData$trips <- as.integer(tripData$trips)




# Create entries for stations with 0 trips for a given hour ################################################################

# Create dataframe of all possible date-hour-station combinations
allSlots <- expand.grid(citiStationID=unique(tripData$citiStationID),
                        hour=(0:23),
                        date=seq(from=as.Date("2014-01-01"), to=as.Date("2014-12-31"), by=1))

# Join allSlots and tripData
tripData <- left_join(x=allSlots,
                      y=tripData,
                      by=c("date", "hour", "citiStationID")) %>%
  select(date, hour, citiStationID, trips) %>%
  arrange(date, hour, citiStationID)

# Replace NA trips with 0
tripData$trips[is.na(tripData$trips)] <- 0
tripData$trips <- as.integer(tripData$trips)

# Remove temporary table
rm(allSlots)



# Write tripData to csv ################################################################

write.csv(tripData, file="~/Desktop/all_2014_trips_clean.csv", row.names=F)

