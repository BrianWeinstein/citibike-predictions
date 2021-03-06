
# Load packages ################################################################
library(dplyr)
library(lubridate)
library(ggplot2)
library(glmnet)
library(leaps)
library(reshape2)

options("scipen"=50, "digits"=4)



# Read in all data ################################################################

allDataRaw <- read.csv(file=file.choose(), header=T) # all_data.csv
allData <- allDataRaw



# Format for regression ################################################################

# assign data types
allData$date <- as.Date(fast_strptime(as.character(allData$date), format="%Y-%m-%d"))
allData$hour <- as.factor(allData$hour)
allData$weekday <- as.factor(allData$weekday)
allData$citiStationID <- as.factor(allData$citiStationID)
allData$anyPrecip <- as.factor(allData$anyPrecip)

# new dataset for regression
regData <- allData

# remove rows with missing values
regData <- na.omit(regData) # removes the observations for citiStationID IN (319, 384, 540, 2003)

# Select a subset of stations
set.seed(12)
# stationSubset <- regData %>% group_by(citiStationID) %>% summarize(trips=mean(trips)) %>% arrange(-trips) %>% head(20) # Top stations
stationSubset <- data.frame(citiStationID=sample(unique(regData$citiStationID), size=20, replace=F)) # Random sample
regData <- regData %>% filter(citiStationID %in% stationSubset$citiStationID) %>% mutate(citiStationID=factor(citiStationID))
rm(stationSubset)

# remove either the nearestSubStationDist or the citiStationID column, since they're perfectly correlated
# Keeping citiStaionID performs slightly better
regData$nearestSubStationDist <- NULL
# regData$citiStationID <- NULL

# removing the precip column (using anyPrecip instead)
regData$precip <- NULL

# removing the date column
regData$date <- NULL

# create a model matrix for predictors and a response vector
x <- model.matrix(trips ~ ., regData)[ , -1]
y <- regData$trips

# split into train / test data
set.seed(12)
ndx <- sample(1:nrow(regData), round(nrow(regData)/2), replace=F)
train <- 1:nrow(regData) %in% ndx
test <- !train
trainData <- regData[train, ]
testData <- regData[test, ]
rm(ndx)


# Define error functions ################################################################

# mse
mse <- function(data, predictions){
  mean((data-predictions)^2)
}

# rmse
rmse <- function(data, predictions){
  sqrt(mean((data-predictions)^2))
}

# mae
mae <- function(data, predictions){
  mean(abs(data-predictions))
}


# Ridge ################################################################
ridge.model <- cv.glmnet(x[train, ], y[train], alpha=0, type.measure = "mse")
ridge.bestlambda <- ridge.model$lambda.min

plot(ridge.model)
coef(ridge.model, s=ridge.bestlambda)

ridge.pred <- predict(ridge.model, s=ridge.bestlambda, newx=x[test, ])
ridge.rmse <- rmse(ridge.pred, y[test])
ridge.mae <- mae(ridge.pred, y[test])



# Lasso ################################################################
lasso.model <- cv.glmnet(x[train, ], y[train], alpha=1, type.measure = "mse")
lasso.bestlambda <- lasso.model$lambda.min

plot(lasso.model)
coef(lasso.model, s=lasso.bestlambda)

lasso.pred <- predict(lasso.model, s=lasso.bestlambda, newx=x[test, ])
lasso.rmse <- rmse(lasso.pred, y[test])
lasso.mae <- mae(lasso.pred, y[test])



# Linear least squares ################################################################
lls.model <- lm(trips ~ ., data=(trainData), )
coef(lls.model)
lls.pred <- predict(lls.model, newdata=testData)
lls.rmse <- rmse(lls.pred, testData$trips)
lls.mae <- mae(lls.pred, testData$trips)



# Polynomial least squares ################################################################ 

pls.errors <- data.frame()
for (ndx.maxTemp in 1:20){
  pls.model <- lm(trips ~ hour + weekday + citiStationID + avgSubStationStatus + anyPrecip + poly(maxTemp, ndx.maxTemp), data=trainData)
  trainError <- rmse(trainData$trips, predict(pls.model, trainData))
  testError <- rmse(testData$trips, predict(pls.model, testData)) 
  pls.errors <- rbind(pls.errors, data.frame(ndx.maxTemp=ndx.maxTemp, trainError=trainError, testError=testError))
  rm(trainError, testError)
}
pls.errors

# select best model
pls.minerr <- pls.errors[grep(min(pls.errors$testError), pls.errors$testError), ]
pls.bestdeg <- pls.minerr$ndx.maxTemp
pls.model <- lm(trips ~ hour + weekday + citiStationID + avgSubStationStatus + anyPrecip + poly(maxTemp, pls.bestdeg), data=trainData)
pls.rmse <- pls.minerr$testError

# plot errors
ggplot(pls.errors, aes(x=ndx.maxTemp, y=testError)) + geom_line() + geom_point() + 
  geom_vline(xintercept=pls.bestdeg, color="darkgray", linetype="dashed") + 
  xlab("maxTemp Polynomial Degree") + ylab("Test RMSE") + theme_bw()
ggsave(filename='pls_testError_vs_polyDegree.png', width=4, height=2)

ggplot(melt(data=pls.errors, id.vars="ndx.maxTemp", measure.vars = c("trainError","testError"), value.name = "error"), 
       aes(x=ndx.maxTemp, y=error, color=variable)) + geom_line() + geom_point()



# Best subset ################################################################ 
bss <- regsubsets(trips ~ ., data=trainData, nvmax=8)
summary(bss)
plot(bss$rss)
summary(bss)$adjr2
coef(bss, 8)



# Compare and contextualize errors ################################################################ 

ridge.rmse
lasso.rmse
lls.rmse
pls.rmse

