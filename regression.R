
# Load packages ################################################################
library(dplyr)
library(lubridate)
library(ggplot2)
library(glmnet)

options("scipen"=50, "digits"=4)



# Read in all data ################################################################

allDataRaw <- read.csv(file=file.choose(), header=T) # all_data.csv
allData <- allDataRaw



# Format for regression ################################################################

# remove rows with missing values
allData <- na.omit(allData) # removes the observations for citiStationID IN (319, 384, 540, 2003), 
                            # which existed in 2014, but have since been closed

# for now, using only the 10 stations with the highest average trips/hour
topCitiStations <- allData %>% group_by(citiStationID) %>% summarize(trips=mean(trips)) %>% arrange(-trips) %>% head(10)
allData <- allData %>% filter(citiStationID %in% topCitiStations$citiStationID) %>% mutate(citiStationID=factor(citiStationID))
rm(topCitiStations)

# for now, removing the precip column (using anyPrecip instead)
allData$precip <- NULL

# assign data types
allData$date <- as.Date(fast_strptime(as.character(allData$date), format="%Y-%m-%d"))
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



# Ridge ################################################################
ridge.model <- cv.glmnet(x[train, ], y[train], alpha=1, type.measure = "mse")
ridge.bestlambda <- ridge.model$lambda.min

plot(ridge.model)
coef(ridge.model, s=ridge.bestlambda)

ridge.pred <- predict(ridge.model, s=ridge.bestlambda, newx=x[test, ])
ridge.mse <- mse(ridge.pred, y[test])



# Least squares ################################################################
ls.model <- lm(trips ~ ., data=(trainData))
coef(ls.model)
ls.pred <- predict(ls.model, newdata=testData)
ls.mse <- mse(ls.pred, (allData$trips)[test])

