
# Load packages ################################################################
library(dplyr)
library(lubridate)
library(ggplot2)
library(glmnet)
library(reshape2)

options("scipen"=50, "digits"=4)



# Read in all data ################################################################

allDataRaw <- read.csv(file=file.choose(), header=T) # all_data.csv
allData <- allDataRaw



# Format for regression ################################################################

# remove rows with missing values
allData <- na.omit(allData) # removes the observations for citiStationID IN (319, 384, 540, 2003), 
                            # which existed in 2014, but have since been closed


# Options

# A. Run on the full dataset [too large]
#     allData <- allData

# B. Run using only the 10 stations with the highest average trips/hour [high error]
#     topCitiStations <- allData %>% group_by(citiStationID) %>% summarize(trips=mean(trips)) %>% arrange(-trips) %>% head(10)
#     allData <- allData %>% filter(citiStationID %in% topCitiStations$citiStationID) %>% mutate(citiStationID=factor(citiStationID))
#     rm(topCitiStations)

# C. Run one station at a time (using only one station for now) [outputs models with higher Adjusted R2, but still large mse/mean(trips)]
    allData <- filter(allData, citiStationID=="521")
    allData$citiStationID <- NULL
    allData$nearestSubStationDist <- NULL

# D. Aggregate the dataset to daily values [outputs models with highest Adjusted R2, and lowest (but still large) mse/mean(trips)]
#     allData <- allData %>%
#       group_by(date, citiStationID) %>% 
#       summarize(weekday=weekday[1],
#                 trips=sum(trips),
#                 nearestSubStationDist=nearestSubStationDist[1],
#                 avgSubStationStatus=mean(avgSubStationStatus), # averaging the hourly modes?
#                 precip=precip[1],
#                 anyPrecip=anyPrecip[1],
#                 maxTemp=maxTemp[1]) %>%
#       as.data.frame()

# Options end.


# remove either the nearestSubStationDist or the citiStationID column, since they're perfectly correlated
allData$nearestSubStationDist <- NULL
# allData$citiStationID <- NULL

# removing the precip column (using anyPrecip instead)
allData$precip <- NULL

# assign data types
allData$date <- as.Date(fast_strptime(as.character(allData$date), format="%Y-%m-%d"))
allData$hour <- as.factor(allData$hour)
allData$weekday <- as.factor(allData$weekday)
allData$citiStationID <- as.factor(allData$citiStationID)
allData$anyPrecip <- as.factor(allData$anyPrecip)

# create a model matrix for predictors and a response vector
x <- model.matrix(trips ~ ., allData)[ , -1]
y <- allData$trips

# split into train / test data
set.seed(12)
ndx <- sample(1:nrow(allData), round(nrow(allData)/2), replace=F)
train <- 1:nrow(allData) %in% ndx
test <- !train
trainData <- allData[train, ]
testData <- allData[test, ]
rm(ndx)


# Define functions ################################################################

# mse
mse <- function(data, predictions){
  mean((data-predictions)^2)
}

# rmse
rmse <- function(data, predictions){
  sqrt(mean((data-predictions)^2))
}


# Lasso ################################################################
lasso.model <- cv.glmnet(x[train, ], y[train], alpha=1, type.measure = "mse")
lasso.bestlambda <- lasso.model$lambda.min

plot(lasso.model)
coef(lasso.model, s=lasso.bestlambda)

lasso.pred <- predict(lasso.model, s=lasso.bestlambda, newx=x[test, ])
lasso.mse <- mse(lasso.pred, y[test])
sqrt(lasso.mse)


# Ridge ################################################################
ridge.model <- cv.glmnet(x[train, ], y[train], alpha=0, type.measure = "mse")
ridge.bestlambda <- ridge.model$lambda.min

plot(ridge.model)
coef(ridge.model, s=ridge.bestlambda)

ridge.pred <- predict(ridge.model, s=ridge.bestlambda, newx=x[test, ])
ridge.mse <- mse(ridge.pred, y[test])
sqrt(ridge.mse)



# Least squares ################################################################
ls.model <- lm(trips ~ ., data=(trainData))
coef(ls.model)
ls.pred <- predict(ls.model, newdata=testData)
ls.mse <- mse(ls.pred, (allData$trips)[test])
sqrt(ls.mse)



# Polynomial least squares ################################################################ 

poly.errors <- data.frame()
for (ndx.maxTemp in 1:7){ #9:11
  poly.model <- lm(trips ~ hour + weekday + avgSubStationStatus + anyPrecip + poly(maxTemp, ndx.maxTemp), data=allData[train, ])
  trainError <- mse((allData[train, ])$trips, predict(poly.model, (allData[train, ])))
  testError <- mse((allData[test, ])$trips, predict(poly.model, (allData[test, ]))) 
  poly.errors <- rbind(poly.errors, data.frame(ndx.maxTemp=ndx.maxTemp, trainError=trainError, testError=testError, sqrtTestError=sqrt(testError)))
}
rm(trainError, testError)
poly.errors

# select best model
poly.minerr <- poly.errors[grep(min(poly.errors$testError), poly.errors$testError), ]
poly.bestdeg <- poly.minerr$ndx.maxTemp
poly.model <- lm(trips ~ weekday + anyPrecip + poly(maxTemp, poly.bestdeg), data=allData[train, ])
poly.mse <- poly.minerr$testError
sqrt(poly.mse)

# plot errors
ggplot(poly.errors, aes(x=ndx.maxTemp, y=testError)) + geom_line() + geom_point()
ggplot(melt(data=poly.errors, id.vars="ndx.maxTemp", measure.vars = c("trainError","testError"), value.name = "error"), 
       aes(x=ndx.maxTemp, y=error, color=variable)) + geom_line() + geom_point()


