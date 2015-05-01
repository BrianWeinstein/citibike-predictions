
# Load packages ################################################################
library(dplyr)



# Read in station lines and hourly line status ################################################################

# mta_station_lines.csv
stationLines <- read.csv(file=file.choose(), header=T, col.names=c("subStationID", "line"))

# mta_status_hourly.csv
lineStatus <- read.csv(file=file.choose(), header=F, col.names=c("timestamp", "line", "status"))



# Clean lineStatus table ################################################################

lineStatus <- lineStatus %>%
  mutate(date=as.Date(substr(lineStatus$timestamp, 1, 10)),
         hour=as.integer(substr(lineStatus$timestamp, 12, 13))) %>%
  select(date, hour, line, status)

# Note the missing data for G train on July 26-27
# lineStatus %>% filter(status==0)
# lineStatus %>% filter(line=="G" & (date=="2014-07-26" | date=="2014-07-27"))



# Join ################################################################

stationStatus <- left_join(x=lineStatus, y=stationLines, by="line") %>% 
  group_by(date, hour, subStationID) %>% 
  summarize(avgStatus=mean(status))



# Write to csv ################################################################

write.csv(stationStatus, file="~/Desktop/mta_station_status_hourly.csv", row.names=F)


