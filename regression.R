
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

# assign data types
allData$date <- as.Date(fast_strptime(as.character(allData$date), format="%Y-%m-%d"))
allData$weekday <- as.factor(allData$weekday)
allData$citiStationID <- as.factor(allData$citiStationID)
allData$anyPrecip <- as.factor(allData$anyPrecip)

# remove rows with missing values
allData <- na.omit(allData) # removes the observations for citiStationID IN (319, 384, 540, 2003), 
                            # which existed in 2014, but have since been closed

# for now, using only the 10 stations with the highest average trips/hour
topCitiStations <- allData %>% group_by(citiStationID) %>% summarize(trips=mean(trips)) %>% arrange(-trips) %>% head(10)
allData <- allData %>% filter(citiStationID %in% topCitiStations$citiStationID) %>% mutate(citiStationID=factor(citiStationID))
rm(topCitiStations)

# for now, removing the precip column (using anyPrecip instead)
allData$precip <- NULL



# create a model matrix for predictors and a response vector
x <- model.matrix(trips ~ ., allData)[, -1]
y <- allData$trips

# split into train / test data
set.seed(12)
train <- sample(c(T,F), nrow(x), replace=T)
test <- !train



ndx <- sample(1:nrow(allData), round(nrow(allData)/2), replace=F)
train <- 1:nrow(allData) %in% ndx
test <- !train
rm(ndx)


# Lasso ################################################################
lasso.fit <- cv.glmnet(x[train, ], y[train], alpha=1, type.measure = "mse")
lasso.bestlambda <- lasso.fit$lambda.min

plot(lasso.fit)
coef(lasso.fit, s=lasso.bestlambda)


lasso.pred <- predict(lasso.fit, s=lasso.bestlambda, newx=x[test, ])
lasso.mse <- mean((lasso.pred-y[test])^2)



# Ridge ################################################################
ridge.fit <- cv.glmnet(x[train, ], y[train], alpha=1, type.measure = "mse")
ridge.bestlambda <- ridge.fit$lambda.min

plot(ridge.fit)
coef(ridge.fit, s=ridge.bestlambda)


ridge.pred <- predict(ridge.fit, s=ridge.bestlambda, newx=x[test, ])
ridge.mse <- mean((ridge.pred-y[test])^2)



# Least squares ################################################################
ls.fit <- lm(trips ~ ., data=(allData[train, ]))
coef(ls.fit)
ls.pred <- predict(ls.fit, newdata=allData[test, ])
ls.mse <- mean((ls.pred-(allData$trips)[test])^2)






