
# Load packages
library(dplyr)
library(lubridate)
library(ggplot2)

options("scipen"=50, "digits"=4)

# Read in all data

allData <- read.csv(file=file.choose(), header=T)

# Assign data types
allData$date <- as.Date(fast_strptime(as.character(allData$date), format="%Y-%m-%d"))
allData$weekday <- as.factor(allData$weekday)
allData$citiStationID <- as.factor(allData$citiStationID)
allData$anyPrecip <- as.factor(allData$anyPrecip)

allData$day <- as.factor(weekdays(allData$date))
allData$day <- factor(allData$day, levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))



# Plots ################################################################


# Average number of trips per station vs hour, broken down by day of week
ggplot(allData %>% group_by(day, hour) %>% summarize(trips=mean(trips)), aes(x=hour, y=trips, color=day)) + 
  geom_point() + 
  geom_line() + 
  xlab("Hour") + ylab("Avg. Departing Trips per Station") + 
  xlim(1,24) +
  labs(color="") +
  theme_bw() + theme(legend.position=c(0.12,0.6)) 
ggsave(filename='trips_vs_hour_day.png', width=8, height=3.5)


# Average number of trips per station vs hour, broken down by weekday vs weekend
ggplot(allData %>% group_by(weekday, hour) %>% summarize(trips=mean(trips)), aes(x=hour, y=trips, color=weekday)) + 
  geom_point() + 
  geom_line(size=1.3) + 
  xlab("Hour") + ylab("Avg. Departing Trips per Station") + 
  xlim(1,24) +
  labs(color="") + 
  theme_bw() +  theme(legend.position=c(0.9,0.8)) + 
  scale_color_hue(labels=c("Weekend","Weekday"))
ggsave(filename='trips_vs_hour_dayend.png', width=8, height=3.5)


# Average number of trips per station per hour vs date
ggplot(allData %>% group_by(date) %>% summarize(trips=mean(trips)), aes(x=date, y=trips)) + 
  geom_point(size=0.9999) + 
  geom_smooth(size=1.3) + 
  xlab("Date") + ylab("Avg. Departing Trips / Hour / Station") + 
  theme_bw()
ggsave(filename='trips_vs_date.png', width=8, height=3.5)
  

# Average number of trips per station per hour vs maxTemp
ggplot(allData %>% group_by(date) %>% summarize(maxTemp=max(maxTemp), trips=mean(trips)), aes(x=maxTemp, y=trips)) + 
  geom_point(size=0.9999) + 
  geom_smooth(size=1.3) + 
  xlab("Temperature (Deg F)") + ylab("Avg. Departing Trips / Hour / Station") + 
  theme_bw()
ggsave(filename='trips_vs_temp.png', width=8, height=3.5)


# Average number of trips per station per hour vs precip
ggplot(allData %>% group_by(date) %>% summarize(precip=max(precip), trips=mean(trips)), aes(x=precip, y=trips)) + 
  geom_point(size=0.9999) + 
  geom_smooth(size=1.3) + 
  xlab("Precipitation (Inch)") + ylab("Avg. Departing Trips / Hour / Station") + 
  theme_bw()
ggsave(filename='trips_vs_precip.png', width=8, height=3.5)


# Average number of trips per station per hour distribution for anyPrecip
ggplot(allData %>% group_by(date) %>% summarize(anyPrecip=anyPrecip[1], trips=mean(trips)), aes(x=trips)) + 
  geom_density(aes(fill=anyPrecip), alpha=0.5, adjust=1/1.2) + 
  xlab("Avg. Departing Trips / Hour / Station") + ylab("[density]") +
  theme_bw() + theme(legend.position=c(0.2,0.8)) + 
  scale_fill_hue(labels=c("No Precipitation","Any Precipitation")) + 
  labs(fill="") + 
  guides(fill = guide_legend(override.aes = list(colour = NULL)))
ggsave(filename='trips_vs_anyPrecip.png', width=8, height=3.5)


# Average number of trips per station per hour vs nearestSubStationDist
ggplot(allData %>% group_by(nearestSubStationDist) %>% summarize(trips=mean(trips)), aes(x=nearestSubStationDist, y=trips)) + 
  geom_point(size=0.9999) + 
  geom_smooth(size=1.3) + 
  xlab("Distance to Nearest Subway Station") + ylab("Avg. Departing Trips / Hour / Station") + 
  theme_bw() + xlim(0,0.015)
ggsave(filename='trips_vs_nearestSubStationDist.png', width=8, height=3.5)


# Average number of trips per station per hour vs avgSubStationStatus
ggplot(allData %>% group_by(avgSubStationStatus) %>% summarize(trips=mean(trips)), aes(x=avgSubStationStatus, y=trips)) + 
  geom_point(size=0.9999) + 
  geom_smooth(size=1.3) + 
  xlab("Status of Nearest Subway") + ylab("Avg. Departing Trips / Hour / Station") + 
  theme_bw() + xlim(1,4)
ggsave(filename='trips_vs_avgSubStationStatus.png', width=8, height=3.5)


