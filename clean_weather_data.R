weather.data.raw <- read.csv("datasets/weather_data_raw.csv")
weather.data <- weather.data.raw[c("DATE", "PRCP", "TMAX")]
names(weather.data) <- c("date", "precipitation", "maxTemperature")
weather.data$date <- as.character(weather.data$date)
weather.data$date <- as.Date(weather.data$date, format = "%Y%m%d")
weather.data$precipitation <- (weather.data$precipitation / 10) / 25.4 #Converting to inches...
weather.data$maxTemperature <- (weather.data$maxTemperature / 10) * 9/5 + 32 #Converting to Farenheit...
write.csv(weather.data, "datasets/weather_data.csv")