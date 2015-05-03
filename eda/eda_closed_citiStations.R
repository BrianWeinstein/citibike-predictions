tripData <- read.csv(file=file.choose(), header=T) # all_2014_trips.csv
locData <- read.csv(file=file.choose(), header=T) # citibike_station_data.csv


tripData <- unique(select(tripData, citiStationID))
locData <- unique(select(locData, citiStationID=station_id))

missing <- tripData[!(tripData$citiStationID %in% locData$citiStationID),]

missingData <- filter(allData, citiStationID %in% missing)

missingDataGrouped <- missingData %>% group_by(month=substr(date,1,7), citiStationID) %>% summarize(trips=sum(trips)) %>% as.data.frame()
allOthers <- allData %>% filter(!(citiStationID %in% missing)) %>% 
  group_by(month=substr(date,1,7), citiStationID) %>% summarize(trips=sum(trips)) %>%
  group_by(month) %>% summarize(trips=mean(trips)) %>% as.data.frame() %>% mutate(citiStationID="other")

ggplot(missingDataGrouped, aes(x=month, y=trips, color=citiStationID, group=citiStationID)) + geom_line() + geom_point()

all <- rbind(missingDataGrouped,allOthers)
ggplot(all, aes(x=month, y=trips, color=citiStationID, group=citiStationID)) + geom_line() + geom_point()
