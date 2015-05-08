
# Load packages ################################################################
library(dplyr)
library(lubridate)
library(ggplot2)

options("scipen"=50, "digits"=4)

# Read in all data ################################################################

allData <- read.csv(file=file.choose(), header=T)

allData$date <- as.Date(fast_strptime(as.character(allData$date), format="%Y-%m-%d"))
allData$weekday <- as.factor(allData$weekday)
allData$citiStationID <- as.factor(allData$citiStationID)
allData$anyPrecip <- as.factor(allData$anyPrecip)


###################################################################################
# EDA #############################################################################

# hour, month #############################################################################

# avg trips/station vs hour
ggplot(allData %>% group_by(hour, citiStationID) %>% summarize(trips=mean(trips)), aes(x=hour, y=trips)) + 
  geom_point() + geom_boxplot(aes(group=hour)) + geom_smooth()

# For the 100th most popular station, avg trips vs hour by day of week
ggplot(allData %>% filter(citiStationID==511) %>% group_by(weekday, hour, citiStationID) %>% summarize(trips=mean(trips)), aes(x=hour, y=trips, group=weekday, color=weekday)) + 
  geom_point() + geom_line(se=F, stat="smooth", alpha=0.3, size=1.5) + geom_line(size=1.5)

# Average number of trips (for all stations) vs hour, broken down by weekday
ggplot(allData %>% group_by(weekday, hour) %>% summarize(trips=mean(trips)), aes(x=hour, y=trips, group=weekday, color=weekday)) + 
  geom_point() + geom_line(se=F, stat="smooth", alpha=0.3, size=1.5) + geom_line(size=1.5)

# Average number of trips vs month
ggplot(allData %>% group_by(month=substr(date,1,7)) %>% summarize(trips=mean(trips)), aes(x=month, y=trips)) + 
  geom_point() + geom_line(se=F, stat="smooth", alpha=0.3, size=1.5) + geom_line(size=1.5)


# weekday #############################################################################

# avg tips/station vs weekday
ggplot(allData %>% group_by(weekday, citiStationID) %>% summarize(trips=mean(trips)), aes(x=weekday, y=trips)) + 
  geom_point() + geom_boxplot(aes(group=weekday)) + geom_smooth()


# maxTemp #############################################################################

# daily trips vs temp
ggplot(allData %>% group_by(date) %>% summarize(maxTemp=max(maxTemp), trips=sum(trips)), aes(x=maxTemp, y=trips)) + 
  geom_point() + geom_smooth(size=1.5)

# For the most popular station, trips vs temp, broken down by weekday. Different trends for weekday vs weekend
ggplot(allData %>% filter(citiStationID==521) %>% group_by(date, weekday, citiStationID) %>% summarize(maxTemp=max(maxTemp), trips=sum(trips)), aes(x=maxTemp, y=trips, group=weekday, color=weekday)) + 
  geom_point() + geom_smooth()

# For the most popular station, trips vs temp, broken down by day of week. Different trends for weekday vs weekend
ggplot(allData %>% filter(citiStationID==521) %>% group_by(date, weekday) %>% summarize(maxTemp=max(maxTemp), trips=mean(trips)), aes(x=maxTemp, y=trips, group=weekday, color=weekday)) + 
  geom_point() + geom_smooth()



# precip #############################################################################

# daily trips vs precip
ggplot(allData %>% group_by(date) %>% summarize(precip=mean(precip), trips=mean(trips)), aes(x=precip, y=trips)) + 
  geom_point() + geom_smooth(size=1.5)

# daily trips vs hour, by anyPrecip
ggplot(allData %>% group_by(hour, anyPrecip) %>% summarize(trips=mean(trips)), aes(x=hour, y=trips, group=anyPrecip, color=anyPrecip)) + 
  geom_point() + geom_line(se=F, stat="smooth", alpha=0.2, size=1.5) + geom_line(size=1.5)




# subway stuff #############################################################################

ggplot(allData %>% group_by(nearestSubStationDist) %>% summarize(trips=mean(trips)), aes(x=nearestSubStationDist, y=trips)) + 
  geom_point() + geom_smooth() + xlim(0,0.01)

ggplot(allData %>% group_by(avgSubStationStatus) %>% summarize(trips=mean(trips)), aes(x=avgSubStationStatus, y=trips)) + 
  geom_point() + geom_smooth()

ggplot(allData %>% group_by(date, avgSubStationStatus) %>% summarize(trips=mean(trips)), aes(x=avgSubStationStatus, y=trips)) + 
  geom_point() + geom_smooth()





